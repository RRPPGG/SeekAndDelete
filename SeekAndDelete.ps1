$PrintAllFiles = 0
$RootPath = pwd
$CompareByName = 1
$CompareBySize = 1
$CompareByDate = 1
$FileExtension = "" #Empty means all
$OutputFile = "$RootPath\DuplicatedFiles.txt"

$AllFiles = New-Object System.Collections.ArrayList

$ToDoDirs = New-Object System.Collections.ArrayList
[void]$ToDoDirs.Add($RootPath)

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
        }
        else
        {
            if (($FileExtension -eq "") -or ($FileExtension -eq [IO.Path]::GetExtension($File)))
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
    $ToDoDirs.RemoveAt(0)
}

echo "Number of files found: $($AllFiles.Count)"

if ($PrintAllFiles -eq 1)
{
    for ($i=0; $i -lt $AllFiles.Count; $i++)
    {
        echo "$($AllFiles[$i].FullName) $($AllFiles[$i].Size) $($AllFiles[$i].Date)"
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
        if ($CompareByName -eq 1)
        {
            if ($AllFiles[$i].Name -ne $AllFiles[$j].Name)
            {
                continue
            }
        }
        if ($CompareBySize -eq 1)
        {
            if ($AllFiles[$i].Size -ne $AllFiles[$j].Size)
            {
                continue
            }
        }
        if ($CompareByDate -eq 1)
        {
            if ($AllFiles[$i].Date.ToString('u') -ne $AllFiles[$j].Date.ToString('u'))
            {
                continue
            }
        }
        $SameGroup += $AllFiles[$j].FullName
        $AllFiles.RemoveAt($j)
    }
    if ($SameGroup.Count -gt 1)
    {
        if ($AtLeastOneFound -eq 0)
        {
            $AtLeastOneFound = 1
            "SeekAndDelete raport for $RootPath" > $OutputFile
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
    echo "Congratulations, you don't have any duplicated files in this directory"
}
else
{
    echo "Your duplicated file list is in $OutputFile"
}
echo "Done. Thank you for using SeekAndDelete"

pause