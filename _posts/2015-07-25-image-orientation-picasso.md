---
title:  "Image orientation bug with Picasso"
date:   2015-07-25
tags: [Android]
---

Short memo about an issue I just had some issue on Android with Picasso library when loading an image from a URI on KitKat.

The issue on GitHub seems to be this one:

https://github.com/square/picasso/issues/566

This gist is a workaround to the issue, but it did not work for me out of the box.

https://gist.github.com/dnkoutso/9e34a1bba3d63034e863

This seems to work only with `document://` kind of URLs because of `DocumentsContract.getDocumentId(uri)`.

Finally, here is the code I used to get this to work properly.

```java
package com.example.util;

import android.annotation.TargetApi;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.net.Uri;
import android.os.Build;
import android.provider.MediaStore;

import com.squareup.picasso.Transformation;

@TargetApi(Build.VERSION_CODES.KITKAT)
public class ExifTransformation implements Transformation {
    private static final String[] CONTENT_ORIENTATION = new String[] {
            MediaStore.Images.ImageColumns.ORIENTATION
    };

    final Context context;
    final Uri uri;

    public ExifTransformation(Context context, Uri uri) {
        this.context = context;
        this.uri = uri;
    }

    @Override
    public Bitmap transform(Bitmap source) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) return source;

        int exifRotation = getExifOrientation(context, uri);
        if (exifRotation != 0) {
            Matrix matrix = new Matrix();
            matrix.preRotate(exifRotation);

            Bitmap rotated =
                    Bitmap.createBitmap(source, 0, 0, source.getWidth(), source.getHeight(), matrix, true);
            if (rotated != source) {
                source.recycle();
            }
            return rotated;
        }

        return source;
    }

    @Override
    public String key() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) return "documentTransform()";
        return "documentExifTransform(" + uri.toString() + ")";
    }

    public static int getExifOrientation(Context context, Uri photoUri) {
        Cursor cursor = context.getContentResolver().query(photoUri, CONTENT_ORIENTATION, null, null, null);

        if (cursor.getCount() != 1) {
            return -1;
        }

        cursor.moveToFirst();
        return cursor.getInt(0);
    }
}
```

When loading the image, the following then gave the wanted result:

```java
Picasso
    .with(this)
    .load(uri)
    .transform(new ExifTransformation(this, uri))
    .into(imageView);
```
