#!/usr/bin/perl
#
# ART export script for Modo, to the Hood engine
# Versions: MODO 701/902
#
# User Guide:
# See art.pl for instructions
#

sub ExportUnwrap {
    my ($FileName) = @_;
	
    # Writes in file append mode >>
    open(my $F, '>>', $FileName) or die "Could not open file '$FileName' $!";
    binmode($F);

    # Selects texture map
    my $VMapCount = lxq("query layerservice vmap.n ? all");
    my $TextureVMap = -1;
	
    for (my $i = 0; $i < $VMapCount; $i++) {
        if ((lxq("query layerservice vmap.type ? $i") eq "texture") && (lxq("query layerservice vmap.selected ? $i") == 1)) {
            $TextureVMap = $i;
            last;
        }
    }

    # Checks if you selected a texture.
    if ($TextureVMap == -1) {
        die("No selected texture vertex map in this layer so the script is cancelled.");
    }

    my @Faces = lxq("query layerservice polys ? all");

    my $SectorName = "VMAP";
    print $F $SectorName;

    my $PolyCount = scalar @Faces;
    print $F pack('i', $PolyCount);

    foreach my $Face (@Faces) {
        my @FaceUVPosition = lxq("query layerservice poly.vmapValue ? $Face");
        my @Faces = lxq("query layerservice poly.vertList ? $Face");

        my $FaceVertexCount = scalar @Faces;
        my $UVOffset = $FaceVertexCount == 4 ? 2 : 3;  # Checks if face is a quad or a tri.

        for (my $i = 0, my $j = 0; $i < scalar @FaceUVPosition; $i += 2, $j++) {

            my $VertexIndex = $Faces[$j % $FaceVertexCount];

            my @VertexPositions = lxq("query layerservice vert.pos ? $VertexIndex");

            my $U = $FaceUVPosition[$i];
            my $V = $FaceUVPosition[$i + 1];

            print $F pack('i', $VertexIndex);
            print $F pack('f3', @VertexPositions);
            print $F pack('f2', $U, $V);

	}
    }

    close($F);
	
}

1; # Submodule
