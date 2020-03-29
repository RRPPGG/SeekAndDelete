param (
    [string]$rootdir = $pwd,
    [string]$filetype = "", #Empty means all
    [switch]$ignoreName = $false,
    [switch]$ignoreSize = $false,
    [switch]$ignoreDate = $false,
    [switch]$directorymode = $false
 )

if (($ignoreName -eq $true) -and ($ignoreSize -eq $true) -and($ignoreDate -eq $true))
{
    echo "Ignoring name, size and date makes no sense - exiting..."
    pause
}

if ($directorymode -eq $true)
{
    echo "Running in directory mode - filetype option is disabled, ignoreName and ignoreDate are set to true"
    $ignoreName = $true
    $ignoreDate = $true
}

$PrintAllFiles = 0
$ScriptPath = pwd
$OutputFile = "$ScriptPath\DuplicatedFiles.txt"

$AllFiles = New-Object System.Collections.ArrayList

$ToDoDirs = New-Object System.Collections.ArrayList
[void]$ToDoDirs.Add($rootdir)

echo "SeekAndDelete starting, looking for files..."

while ($ToDoDirs.Count -gt 0)
{
    cd $ToDoDirs[0]

    $LsFiles = ls .
    foreach ($File in $LsFiles)
    {
        if ((Get-Item $File) -is [System.IO.DirectoryInfo])
        {
            [void]$ToDoDirs.Add("$pwd\$File")
            if ($directorymode -eq $true)
            {
                $fileObject = New-Object -TypeName PSObject
                $fileObject | Add-Member -Name 'FullName' Noteproperty -Value $File.FullName
                $fileObject | Add-Member -Name 'Size' Noteproperty -Value (gci -force -Recurse $File | measure Length -s).sum
                $fileObject | Add-Member -Name 'Files' Noteproperty -Value (Get-ChildItem $File).Name
                [void]$AllFiles.Add($fileObject)
            }
        }
        else
        {
            if ($directorymode -eq $false)
            {
                if (($filetype -eq "") -or ($filetype -eq [IO.Path]::GetExtension($File)))
                {
                    $fileObject = New-Object -TypeName PSObject
                    $fileObject | Add-Member -Name 'Name' Noteproperty -Value $File.Name
                    $fileObject | Add-Member -Name 'FullName' Noteproperty -Value $File.FullName
                    $fileObject | Add-Member -Name 'Size' Noteproperty -Value $File.Length
                    $fileObject | Add-Member -Name 'Date' Noteproperty -Value $File.LastWriteTime
                    [void]$AllFiles.Add($fileObject)
                }    
            }
        }
    }
    $ToDoDirs.RemoveAt(0)
}

echo "Number of files found: $($AllFiles.Count)"

if ($PrintAllFiles -eq 1)
{
    for ($i=0; $i -lt $AllFiles.Count; $i++)
    {
        if ($directorymode -eq $false)
        {
            echo "$($AllFiles[$i].FullName) $($AllFiles[$i].Size) $($AllFiles[$i].Date)"
        }
        else
        {
            echo "$($AllFiles[$i].FullName) $($AllFiles[$i].Size) $($AllFiles[$i].Files)"
        }
    }
}

echo "Looking for duplicates..."

$AtLeastOneFound = 0

for ($i=0; $i -lt $AllFiles.Count; $i++)
{
    $SameGroup = @()
    $SameGroup += $AllFiles[$i].FullName
    for ($j=$i+1; $j -lt $AllFiles.Count; $j++)
    {
        if ($ignoreName -eq $false)
        {
            if ($AllFiles[$i].Name -ne $AllFiles[$j].Name)
            {
                continue
            }
        }
        if ($ignoreSize -eq $false)
        {
            if ($AllFiles[$i].Size -ne $AllFiles[$j].Size)
            {
                continue
            }
        }
        if ($ignoreDate -eq $false)
        {
            if ($AllFiles[$i].Date.ToString('u') -ne $AllFiles[$j].Date.ToString('u'))
            {
                continue
            }
        }
        if (($directorymode -eq $true))
        {
            if ([string]$AllFiles[$i].Files -ne [string]$AllFiles[$j].Files)
            {
                continue
            }
        }
        $SameGroup += $AllFiles[$j].FullName
        $AllFiles.RemoveAt($j)
        $j--
    }
    if ($SameGroup.Count -gt 1)
    {
        if ($AtLeastOneFound -eq 0)
        {
            $AtLeastOneFound = 1
            "SeekAndDelete raport for $rootdir" > $OutputFile
        }
        "`nFollowing files are duplicates:" >> $OutputFile
        foreach ($DuplicatedFile in $SameGroup)
        {
            "$DuplicatedFile" >> $OutputFile
        }
    }
}

if ($AtLeastOneFound -eq 0)
{
    echo "Congratulations, you don't have any duplicates in this directory"
}
else
{
    echo "Your duplicated file list is in $OutputFile"
}
echo "Done. Thank you for using SeekAndDelete"
cd $ScriptPath
pause