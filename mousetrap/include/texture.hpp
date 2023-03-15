//
// Copyright 2022 Clemens Cords
// Created on 8/6/22 by clem (mail@clemens-cords.com)
//

#pragma once

#include <string>
#include "gl_common.hpp"
#include "image.hpp"
#include "texture_object.hpp"
#include "wrap_mode.hpp"
#include "scale_mode.hpp"

namespace mousetrap
{
    class Texture : public TextureObject
    {
        public:
            Texture(); // should be called while gl context is bound
            virtual ~Texture();

            Texture(const Texture&) = delete;
            Texture& operator=(const Texture&) = delete;

            Texture(Texture&&);
            Texture& operator=(Texture&&);

            [[nodiscard]] Image download() const;

            void bind(size_t texture_unit) const;

            void bind() const override;
            void unbind() const override;

            void create(size_t width, size_t height);
            void create_from_file(const std::string& path);
            void create_from_image(const Image&);

            void set_wrap_mode(WrapMode);
            WrapMode get_wrap_mode();

            void set_scale_mode(ScaleMode);
            ScaleMode get_scale_mode();

            Vector2i get_size() const;

            GLNativeHandle get_native_handle() const;

        private:
            GLNativeHandle _native_handle = 0;
            WrapMode _wrap_mode = WrapMode::STRETCH;
            ScaleMode _scale_mode = ScaleMode::NEAREST;

            Vector2i _size;
    };
}
