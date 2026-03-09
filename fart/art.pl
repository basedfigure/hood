#!/usr/bin/perl
#
# ART export script for Modo, to the Hood engine
# Versions: MODO 701/902 - with all Hood versions
#
# User Guide:								      
# 1. Change the "require" paths to your local submodule folder (art_vmap.pl).
# 2. Select a mesh layer.							      
# 3. Select a UV map under Lists/UV Maps.					      
# 4. Double-click the unwrapped border in the UV Editor.                           
# 5. Click on Split under the Edge tab to prepare the UV map.          
# 6. Run the script.							      	
#
# There is an equivalent Blender script for this format - i wrote, but this is o
# nly for static models.  I'm not going to create a character exporter for modo, 
# for earlier versions of Modo have very buggy interfaces -- i found some nasty
# bugs in it, years ago. Blender also has bugs, but it's my favorite for technic
# al art, sculpting and options, plus it's open source.
#

# Change these paths to your local submodule folder (art_vmap.pl)
# Linux
require 'mnt/dump_dsk/CENTR/WRK/hood/fart/art_vmap.pl';
# MSWIN
#require 'C:/CENTR/WRK/hood/fart/art_vmap.pl';

# Save dialog
lx("dialog.setup fileSave");
lx("dialog.title [save .art file]");
lx("dialog.fileTypeCustom format:[art] username:[art] loadPattern:[*.art] saveExtension:[art]");
lx("dialog.open");

my $FileName = lxq("dialog.result ?") or die("File not saved.");

# Opens in file save mode ('>')
open(my $F, '>', $FileName) or die "File open failed '$FileName' $!";
binmode($F);

if (lxq("select.typeFrom {vertex;edge;polygon;item} ?") != 1) 
{
    lx("select.convert vertex");
}

my $MainLayer = lxq("query layerservice layers ? main");

my @Vertices = lxq("query layerservice verts ? all");
my @Faces = lxq("query layerservice polys ? all");

lx("select.element $MainLayer vertex set $_") for @Vertices;

my $SectorName = "MESH";
print $F $SectorName;

my $VertexCount = scalar @Vertices;
print $F pack('i', $VertexCount);

my $FaceCount = scalar @Faces;
print $F pack('i', $FaceCount);

foreach my $Vertex (@Vertices) {
  my @VertexPosition = lxq("query layerservice vert.pos ? $Vertex");
  print $F pack('f3', @VertexPosition);
	
  my @VertexNormal = lxq("query layerservice vert.normal ? $Vertex");

  print $F pack('f3', @VertexNormal);  
}

foreach my $Face (@Faces) {
  my @Faces = lxq("query layerservice poly.vertList ? $Face");
  my $Indices = scalar @Faces;
    
  print $F pack('i', $Indices);
    
  foreach my $Face (@Faces) {
        print $F pack('i', $Face);
  }
  
}

close($F);

ExportUnwrap($FileName); # Submodule
