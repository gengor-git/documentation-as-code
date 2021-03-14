<#
Copyright (c) 2018 Martin Palmowski / martin [dot] palmowski [at] gmail [dot] com

This Source Code Form is subject to the terms of the Mozilla Public License,
v.2.0. If a copy of the MPL was not distributed with this file, You can obtain
one at http://mozilla.org/MPL/2.0/.

This Source Code Form is “Incompatible With Secondary Licenses”, as defined by
the Mozilla Public License, v. 2.0.

This script is calling pandoc to render PDFs for all updated markdown
and org-files in the current directory.

Do adjust the $datadir variable to meet your setup.
Run the script from within the folder your markdown/org-files are in or
pass the wanted directory as parameter to the script.

#>

Write-Host "PANDOC SLIDES CREATOR SCRIPT"

#### SETTINGS ####
if(Test-Path $env:Pandoc_Datadir) {
    $datadir = $env:Pandoc_Datadir
} else {
    $datadir = "."
}
$pdf_engine = "xelatex"
$pandoc_opts = "--slide-level=2 -V aspectratio:169"
$input_dir = "."
$output_dir = "."
$run_endless = $false

# If an input directory was given set this instead of the directory the script was run from.
if($($args[0])) {
    $input_dir = $($args[0])
    $output_dir = $($args[0])
    $test_dir = Get-Item $input_dir
    Write-Host "Directory was given as argument: $test_dir"
}

$slides_header = "$datadir\templates\headers\slides.tex"

$loop_active = $true
while($loop_active) {
    # Process the md-files in this directory
    $markdowns = Get-ChildItem $input_dir -Filter *.md
    foreach($markdown in $markdowns){
        # Name the PDF like the MD but with a PDF as extension.
        $out_filename = $markdown.Basename + ".pdf"
        # Build string for the parameters for pandoc
        $params = "-f markdown -t beamer -H $slides_header $pandoc_opts -o `"$output_dir\$out_filename`" `"$input_dir\$markdown`""

        # Check if there is already a PDF with that name, if not render the new pdf.
        if(Test-Path "$output_dir\$out_filename") {
            # Create a file object to check the last modified date, since we only render when the markdown is newer.
            $pdf = Get-Item "$output_dir\$out_filename"
            if($markdown.LastWriteTime -gt $pdf.LastWriteTime) {
                Write-Host "Markdown $markdown is newer. Starting render of $pdf."
                # Write-Host $params
                Start-Process -NoNewWindow -FilePath "pandoc.exe" -ArgumentList $params
            } else {
                Write-Host "Markdown $markdown is NOT newer. Nothing to do! Go grab a cookie."
            }
        } else { # Do this when no PDF was present at all.
            Write-Host "No PDF for $markdown found. Starting render."
            Write-Host $params
            Start-Process -NoNewWindow -FilePath "pandoc.exe" -ArgumentList $params
        }
    }
    if($run_endless) {
        # Pause for a little until the script runs again
        Start-Sleep 10
    } else {
        $loop_active = $run_endless
    }
}
