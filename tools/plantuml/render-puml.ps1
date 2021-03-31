<#
Copyright (c) 2018 Martin Palmowski / martin [dot] palmowski [at] gmail [dot] com

This Source Code Form is subject to the terms of the Mozilla Public License,
v.2.0. If a copy of the MPL was not distributed with this file, You can obtain
one at http://mozilla.org/MPL/2.0/.

This Source Code Form is “Incompatible With Secondary Licenses”, as defined by
the Mozilla Public License, v. 2.0.

This script is calling puml (graphviz) to render svgs for all updated puml
files in the current directory.

Run the script from within the folder your markdown/org-files are in or
pass the wanted directory as parameter to the script.

#>

Write-Host "PlantUML CREATOR SCRIPT"

#### SETTINGS ####
$input_dir = "."
$output_dir = "."
$run_endless = $false
$plantuml_cmd = "java"
$plantuml_opts = "-charset utf8"

# If an input directory was given set this instead of the directory the script was run from.
if($($args[0])) {
    $input_dir = $($args[0])
    $output_dir = $($args[0])
    $test_dir = Get-Item $input_dir
    Write-Host "Directory was given as argument: $test_dir"
}


$loop_active = $true
while($loop_active) {
    # Process the puml-files in this directory
    $pumls = Get-ChildItem $input_dir -Filter *.puml
    foreach($puml in $pumls){
        # Build string for the parameters for pandoc
        $params = "`"$puml`" $plantuml_opts -tsvg"
        $params2 = "`"$puml`" $plantuml_opts -tpng"

        # We don't know the final filename (as that is the title in the file. So let's always render.)
        Write-Host "Processing $puml. Starting render."
        Start-Process -NoNewWindow -FilePath "$plantuml_cmd" -ArgumentList "-jar $env:APPDATA\plantuml.jar $params"
        Start-Process -NoNewWindow -FilePath "$plantuml_cmd" -ArgumentList "-jar $env:APPDATA\plantuml.jar $params2"
    }

    if($env:INKSCAPE) {
        Write-Host "Inkscape parameter found for $env:INKSCAPE."
        Start-Sleep 30
        # Start EPS/PDF conversion (if you have Inkscape)
        $svgs = Get-ChildItem $input_dir -Filter *.svg
        foreach($svg in $svgs) {
            # Run Inkscape to convert them to EPS/PDF, so we can use them in PDF.
            $out_filename_eps = $svg.Basename + ".eps"
            $out_filename_pdf = $svg.Basename + ".pdf"
            $inkscape_params_eps = "`"$input_dir\$svg`" --export-type=eps --export-filename `"$output_dir\$out_filename_eps`""
            $inkscape_params_pdf = "`"$input_dir\$svg`" --export-type=pdf --export-filename `"$output_dir\$out_filename_pdf`""
            # Write-Host $env:INKSCAPE
            Write-Host "Running Inkscape to convert $svg to EPS"
            Start-Process -NoNewWindow -FilePath $env:INKSCAPE -ArgumentList $inkscape_params_eps
            Write-Host "Running Inkscape to convert $svg to PDF"
            Start-Process -NoNewWindow -FilePath $env:INKSCAPE -ArgumentList $inkscape_params_pdf

        }
    }

    if($run_endless) {
        # Pause for a little until the script runs again
        Start-Sleep 10
    } else {
        $loop_active = $run_endless
    }
}
