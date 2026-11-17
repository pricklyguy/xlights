param([string]$RepoPath = (Split-Path -Parent $PSScriptRoot))
$modelsDir=Join-Path $RepoPath 'models'
$previewDir=Join-Path $RepoPath 'previews'
New-Item -ItemType Directory -Path $previewDir -Force | Out-Null
$items=@()
foreach($file in Get-ChildItem -LiteralPath $modelsDir -Filter '*.xmodel' -File | Sort-Object Name){
  $doc=[System.Xml.XmlDocument]::new();$doc.Load($file.FullName)
  $rootNode=[System.Xml.XmlElement]$doc.DocumentElement
  if($rootNode.Name -eq 'models'){$modelNode=[System.Xml.XmlElement]$rootNode.SelectSingleNode('./model')}else{$modelNode=$rootNode}
  $modelName=$modelNode.GetAttribute('name');if(-not $modelName){$modelName=$file.BaseName}
  $display=$modelNode.GetAttribute('DisplayAs')
  $points=[System.Collections.Generic.List[object]]::new();$width=0;$height=0
  $compressed=$modelNode.GetAttribute('CustomModelCompressed')
  $dense=$modelNode.GetAttribute('CustomModel')
  if($compressed){
    foreach($entry in $compressed.Split(';')){ $parts=$entry.Split(',');if($parts.Count -ge 3 -and $parts[0] -match '^\d+$' -and $parts[1] -match '^\d+$'){ $x=[int]$parts[0];$y=[int]$parts[1];$points.Add([pscustomobject]@{X=$x;Y=$y});if($x+1 -gt $width){$width=$x+1};if($y+1 -gt $height){$height=$y+1} } }
    $wAttr=$modelNode.GetAttribute('CustomWidth');$hAttr=$modelNode.GetAttribute('CustomHeight');if($wAttr -match '^\d+$'){$width=[int]$wAttr};if($hAttr -match '^\d+$'){$height=[int]$hAttr}
  }elseif($dense){
    $rows=$dense.Split(';');$height=$rows.Count
    for($y=0;$y -lt $rows.Count;$y++){ $cells=$rows[$y].Split(',');if($cells.Count -gt $width){$width=$cells.Count};for($x=0;$x -lt $cells.Count;$x++){if($cells[$x] -match '^\d+$'){$points.Add([pscustomobject]@{X=$x;Y=$y})}} }
  }
  $safeLeaf=([IO.Path]::GetFileNameWithoutExtension($file.Name) -replace '[^A-Za-z0-9._-]+','-').Trim('-')
  $previewName=$safeLeaf+'.svg';$out=Join-Path $previewDir $previewName
  if($points.Count -gt 0 -and $width -gt 0 -and $height -gt 0){
    $pad=10.0;$canvas=220.0;$scale=[Math]::Min(($canvas-2*$pad)/$width,($canvas-2*$pad)/$height);$ox=($canvas-$width*$scale)/2;$oy=($canvas-$height*$scale)/2;$radius=[Math]::Max(0.55,[Math]::Min(2.0,$scale*0.38));$sb=[System.Text.StringBuilder]::new()
    [void]$sb.AppendLine('<svg xmlns="http://www.w3.org/2000/svg" width="220" height="220" viewBox="0 0 220 220"><rect width="220" height="220" rx="12" fill="#0c1422"/><rect x="5" y="5" width="210" height="210" rx="9" fill="none" stroke="#26364b"/>')
    foreach($pt in $points){$px=[Math]::Round($ox+($pt.X+0.5)*$scale,2);$py=[Math]::Round($oy+($pt.Y+0.5)*$scale,2);[void]$sb.Append('<circle cx="').Append($px).Append('" cy="').Append($py).Append('" r="').Append($radius).AppendLine('" fill="#8ce85a"/>')}
    [void]$sb.AppendLine('</svg>');[IO.File]::WriteAllText($out,$sb.ToString(),[Text.UTF8Encoding]::new($false))
  }else{
    $kind=if($display -eq 'Matrix'){'MATRIX'}elseif($display -match 'Dmx|Moving'){'DMX MODEL'}else{'MODEL PREVIEW'}
    $svg=@('<svg xmlns="http://www.w3.org/2000/svg" width="220" height="220" viewBox="0 0 220 220">','<rect width="220" height="220" rx="12" fill="#0c1422"/><rect x="5" y="5" width="210" height="210" rx="9" fill="none" stroke="#26364b"/>','<rect x="48" y="45" width="124" height="112" rx="8" fill="#14243a" stroke="#86a1bf" stroke-width="3"/><path d="M63 60h94v82H63z" fill="none" stroke="#6f89a5" stroke-width="2"/>','<text x="110" y="190" text-anchor="middle" fill="#a9bbd0" font-family="sans-serif" font-size="12">'+$kind+'</text></svg>')
    [IO.File]::WriteAllLines($out,$svg,[Text.UTF8Encoding]::new($false))
  }
  $nodeLabel=if($points.Count){"$($points.Count) plotted nodes · ${width} × ${height}"}else{if($modelNode.GetAttribute('PixelCount')){"$($modelNode.GetAttribute('PixelCount')) nodes · preview map unavailable"}else{'preview map unavailable'}}
  $items += [pscustomobject]@{File=$file.Name;Model=$modelName;Preview=$previewName;Nodes=$nodeLabel;Display=$display}
}
$md=[System.Text.StringBuilder]::new()
[void]$md.AppendLine('# PricklyGuy xLights Models')
[void]$md.AppendLine()
[void]$md.AppendLine('A visual catalog of the xmodel files in models/. Filenames are preserved as supplied. The Model name in file column shows the name stored inside each xLights file; the name check flags any difference from the filename.')
[void]$md.AppendLine()
[void]$md.AppendLine('Previews show the model node layout when the `.xmodel` contains a custom node map. Other previews identify the model type where no node map is embedded.')
[void]$md.AppendLine()
[void]$md.AppendLine('| Preview | File in repo | Model name in file | Name check | Preview detail |')
[void]$md.AppendLine('|---|---|---|---|---|')
foreach($item in $items){$fileUrl=[uri]::EscapeDataString($item.File);$previewUrl=[uri]::EscapeDataString($item.Preview);$check=if([IO.Path]::GetFileNameWithoutExtension($item.File) -eq $item.Model){"matches"}else{"⚠ differs"};[void]$md.AppendLine("| ![$($item.Model)](previews/$previewUrl) | [$($item.File)](models/$fileUrl) | $($item.Model) | $check | $($item.Nodes) |")}
[void]$md.AppendLine()
[void]$md.AppendLine('The original `.xmodel` files are in [`models/`](models/). Preview SVGs and the generator are in [`previews/`](previews/).')
[IO.File]::WriteAllText((Join-Path $RepoPath 'README.md'),$md.ToString(),[Text.UTF8Encoding]::new($false))
