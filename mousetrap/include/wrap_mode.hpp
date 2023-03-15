//
// Copyright (c) Clemens Cords (mail@clemens-cords.com), created 3/15/23
//

#pragma once

#include "gl_common.hpp"

namespace mousetrap
{
    enum class WrapMode
    {
        ZERO = 0,
        ONE = 1,
        REPEAT = GL_REPEAT,
        MIRROR = GL_MIRRORED_REPEAT,
        STRETCH = GL_CLAMP_TO_EDGE
    };
}
