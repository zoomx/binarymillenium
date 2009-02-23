#

mod_arboard
{
    name          = ArMarkers to X,Y,Rotation
    deterministic = false
    group         = Position
    xpm           = arboardmodule.xpm
    author        = binarymillenium
    version       = 0.0.1
}

inputs
{
    1
    {
        name = video_in
        type = typ_FrameBufferType
        const= true
        strong_dependency = true
    }
}

outputs
{
    x1
    {
        name = X-Position-1
        type = typ_NumberType
    }

    y1
    {
        name = Y-Position-1
        type = typ_NumberType
    }

    r1
    {
        name = R-Position-1
        type = typ_NumberType
    }

    x2
    {
        name = X-Position-2
        type = typ_NumberType
    }

    y2
    {
        name = Y-Position-2
        type = typ_NumberType
    }

    r2
    {
        name = R-Position-2
        type = typ_NumberType
    }


}
