# Source Path for files
$source = "<SOURCEPATH>"
$output = "<OUTPUTPATH>"

# For Wordpress date in URL for files
$urlFolderDate = "<WPFOLDERDATE>" # Syntax: 2018/09
$title = "<TITLE>"

###############################################################################

$directoryListing = New-Object System.Collections.ArrayList
$linkArray = New-Object System.Collections.ArrayList

$directoryListing = Get-ChildItem $source\*.* | Select-Object Name

$tableStart = "<table class=`"avia-table avia-data-table avia-table-1  avia-builder-el-2  el_after_av_one_full  avia-builder-el-last  avia_pricing_default`">
    <tr>
        <th>$title</th>
    </tr>"
$tableEnd = "</table>"

Add-Content -Path $output -Value $tableStart

foreach($fileName in $directoryListing)
{
    $urlFileName = $fileName.Name

    $url = "/wp-content/uploads/$urlFolderDate/$urlFileName"
    
    $title = $fileName.Name
    $title = $title.Replace("-"," ")
    $title = $title.Replace("_"," ")

    $title = $title.Replace(".rfa","")

    # Title for HREF
    #$title

    # URL to file
    #$url
    $url = $url.Replace(" ","-")
    $url = $url.Replace("(","")
    $url = $url.Replace(")","")

$linkForTable = "        
    <tr>
        <td>
            <a href=`"$url`" target=`"_blank`">$title</a>
        </td>
    </tr>"

    $linkForTable | Add-Content -Path $output
}

Add-Content -Path $output -Value $tableEnd
