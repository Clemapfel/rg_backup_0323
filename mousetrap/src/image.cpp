//
// Copyright 2022 Clemens Cords
// Created on 8/6/22 by clem (mail@clemens-cords.com)
//

#include "mousetrap/include/image.hpp"
#include <iostream>

namespace mousetrap
{
    Image::Image(const Image& other)
    {
        _data = std::vector<float>();
        _data.reserve(other._data.size());
        for (auto v : other._data)
            _data.push_back(v);

        _size = other._size;
    }

    Image::Image(Image&& other)
    {
        _data = std::vector<float>();
        _data.reserve(other._data.size());
        for (auto v : other._data)
            _data.push_back(v);

        _size = other._size;

        other._data.clear();
        other._size = {0, 0};
    }

    Image& Image::operator=(const Image& other)
    {
        _data = std::vector<float>();
        _data.reserve(other._data.size());
        for (auto v : other._data)
            _data.push_back(v);

        _size = other._size;

        return *this;
    }

    Image& Image::operator=(Image&& other)
    {
        _data = std::vector<float>();
        _data.reserve(other._data.size());
        for (auto v : other._data)
            _data.push_back(v);

        _size = other._size;

        other._data.clear();
        other._size = {0, 0};

        return *this;
    }

    void Image::create(size_t width, size_t height, RGBA default_color)
    {
        _data.clear();
        _data.reserve(width * height * 4);
        for (size_t i = 0; i < width * height; ++i)
        {
            _data.push_back(default_color.r);
            _data.push_back(default_color.g);
            _data.push_back(default_color.b);
            _data.push_back(default_color.a);
        }

        _size = {width, height};
    }

    void Image::create_from_pixbuf(GdkPixbuf* pixbuf)
    {
        unsigned char* buffer = gdk_pixbuf_get_pixels(pixbuf);

        bool has_alpha = gdk_pixbuf_get_has_alpha(pixbuf);
        size_t padding_bytes = gdk_pixbuf_get_rowstride(pixbuf) / sizeof(unsigned char) - gdk_pixbuf_get_width(pixbuf) * (has_alpha ? 4 : 3);
        _size = {gdk_pixbuf_get_width(pixbuf) - padding_bytes, gdk_pixbuf_get_height(pixbuf)};
        size_t n = _size.x * _size.y * (has_alpha ? 4 : 3);

        _data.clear();
        _data.reserve(n);

        for (size_t i = 0; i < n; ++i)
        {
            _data.push_back(buffer[i] / 255.f);

            if (not has_alpha)
                _data.push_back(1);
        }
    }

    bool Image::create_from_file(const std::string& path)
    {
        GError* error_maybe = nullptr;
        auto* pixbuf = gdk_pixbuf_new_from_file(path.c_str(), &error_maybe);

        if (error_maybe != nullptr)
        {
            std::cerr << "[WARNING] In Image::create_from_file: unable to open file \"" << path << "\"" << std::endl;
            _data.clear();
            _size = {0, 0};
            return false;
        }

        create_from_pixbuf(pixbuf);
        g_object_unref(pixbuf);
        return true;
    }

    void Image::create_from_texture(GdkTexture* texture)
    {
        auto size = Vector2ui(gdk_texture_get_width(texture), gdk_texture_get_height(texture));

        // FORMAT: ARGB32, c.f. https://docs.gtk.org/gdk4/method.Texture.download.html

        auto* surface = cairo_image_surface_create (CAIRO_FORMAT_ARGB32,gdk_texture_get_width(texture), gdk_texture_get_height(texture));
        gdk_texture_download(texture,cairo_image_surface_get_data(surface),cairo_image_surface_get_stride(surface));
        auto* data = cairo_image_surface_get_data(surface);

        create(size.x, size.y);
        for (size_t i = 0; i < size.x * size.y * 4; i = i + 4)
        {
            guchar b = data[i+0];
            guchar g = data[i+1];
            guchar r = data[i+2];
            guchar a = data[i+3];

            _data[i+0] = float(r) / 255.f;
            _data[i+1] = float(g) / 255.f;
            _data[i+2] = float(b) / 255.f;
            _data[i+3] = float(a) / 255.f;
        }

        cairo_surface_mark_dirty(surface);
        g_free(surface);
    }

    GdkPixbuf* Image::to_pixbuf() const
    {
        auto* out = gdk_pixbuf_new(GDK_COLORSPACE_RGB, true, 8, _size.x, _size.y);
        auto* data = gdk_pixbuf_get_pixels(out);

        for (size_t i = 0; i < _data.size(); ++i)
            data[i] = uint8_t(_data.at(i) * 255.f);

        return out;
    }

    bool Image::save_to_file(const std::string& path) const
    {
        if (_size.x == 0 and _size.y == 0)
        {
            std::cerr << "[WARNING] In Image::save_to_file: Attempting to write an image of size 0x0 to disk, no file will be generated." << std::endl;
            return false;
        }

        auto* as_pixbuf = to_pixbuf();
        GError* error = nullptr;

        gdk_pixbuf_save(as_pixbuf, path.c_str(), "png", &error, NULL);
        if (error != nullptr)
        {
            std::cerr << "[ERROR] In Image::save_to_file: " << error->message << std::endl;
            return false;
        }

        return true;
    }

    Vector2ui Image::get_size() const
    {
        return _size;
    }

    void* Image::data() const
    {
        return (void*) _data.data();
    }

    size_t Image::get_data_size() const
    {
        return _data.size();
    }

    size_t Image::get_n_pixels() const
    {
        return get_size().x * get_size().y;
    }

    size_t Image::to_linear_index(size_t x, size_t y) const
    {
        return y * (_size.x * 4) + (x * 4);
    }

    void Image::set_pixel(size_t x, size_t y, RGBA color)
    {
        auto i = to_linear_index(x, y);

        if (i >= _data.size())
        {
            std::cerr << "[ERROR] In Image::set_pixel: indices " << x << " " << y << " are out of bounds for an image of size " << _size.x << "x" << _size.y << std::endl;
            return;
        }

        _data.at(i) = color.r;
        _data.at(i+1) = color.g;
        _data.at(i+2) = color.b;
        _data.at(i+3) = color.a;
    }

    void Image::set_pixel(size_t x, size_t y, HSVA color)
    {
        set_pixel(x, y, color.operator RGBA());
    }

    RGBA Image::get_pixel(size_t x, size_t y) const
    {
        auto i = to_linear_index(x, y);

        if (i >= _data.size())
        {
            std::cerr << "[ERROR] In Image::get_pixel: indices " << x << " " << y << " are out of bounds for an image of size " << _size.x << "x" << _size.y << std::endl;
            return RGBA(0, 0, 0, 0);
        }

        return RGBA
        (
        _data.at(i),
        _data.at(i+1),
        _data.at(i+2),
        _data.at(i+3)
        );
    }

    void Image::set_pixel(size_t i, RGBA color)
    {
        i *= 4;

        if (i >= _data.size())
        {
            std::cerr << "[ERROR] In Image::set_pixel: index " << i / 4 << " out of bounds for an image of with " << _size.x * _size.y << " pixels" << std::endl;
            return;
        }

        _data.at(i) = color.r;
        _data.at(i+1) = color.g;
        _data.at(i+2) = color.b;
        _data.at(i+3) = color.a;
    }

    void Image::set_pixel(size_t i, HSVA color_hsva)
    {
        auto color = color_hsva.operator RGBA();

        i *= 4;

        if (i >= _data.size())
        {
            std::cerr << "[ERROR] In Image::set_pixel: index " << i / 4 << " out of bounds for an image of with " << _size.x * _size.y << " pixels" << std::endl;
            RGBA(0, 0, 0, 0);
        }

        _data.at(i) = color.r;
        _data.at(i+1) = color.g;
        _data.at(i+2) = color.b;
        _data.at(i+3) = color.a;
    }

    RGBA Image::get_pixel(size_t i) const
    {
        i *= 4;

        return RGBA
        (
        _data.at(i),
        _data.at(i+1),
        _data.at(i+2),
        _data.at(i+3)
        );
    }

    Image Image::as_cropped(int offset_x, int offset_y, size_t size_x, size_t size_y) const
    {
        auto out = Image();
        out.create(size_x, size_y);

        for (size_t y = 0; y < size_y; ++y)
        {
            for (size_t x = 0; x < size_x; ++x)
            {
                Vector2i pos = {x - offset_x, y - offset_y};

                if (pos.x < 0 or pos.x >= get_size().x or pos.y < 0 or pos.y >= get_size().y)
                    out.set_pixel(x, y, RGBA(0, 0, 0, 0));
                else
                    out.set_pixel(x, y, get_pixel(pos.x, pos.y));
            }
        }

        return out;
    }

    Image Image::as_scaled(size_t size_x, size_t size_y, GdkInterpType interpolation_type) const
    {
        if (int(size_x) == _size.x and int(size_y) == _size.y)
            return *this;

        if (size_x == size_t(0))
            size_x = 1;

        if (size_y == size_t(0))
            size_y = 1;

        GdkPixbuf* unscaled = g_object_ref(to_pixbuf());
        auto scaled = g_object_ref(gdk_pixbuf_scale_simple(unscaled, size_x, size_y, interpolation_type));

        auto out = Image();
        out.create_from_pixbuf(scaled);

        g_object_unref(unscaled);
        g_object_unref(scaled);

        return out;
    }

    Image Image::as_flipped(bool flip_horizontally, bool flip_vertically) const
    {
        auto out = Image();
        out.create(_size.x, _size.y);

        for (size_t x = 0; x < _size.x; ++x)
        {
            for (size_t y = 0; y < _size.y; ++y)
            {
                Vector2ui pos = {x, y};

                if (flip_horizontally)
                    pos.x = _size.x - pos.x - 1;

                if (flip_vertically)
                    pos.y = _size.y - pos.y - 1;

                out.set_pixel(pos.x, pos.y, get_pixel(x, y));
            }
        }

        return out;
    }
}