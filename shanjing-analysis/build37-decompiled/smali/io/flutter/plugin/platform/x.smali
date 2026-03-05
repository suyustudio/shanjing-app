.class public Lio/flutter/plugin/platform/x;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lio/flutter/plugin/platform/o;


# annotations
.annotation build Landroid/annotation/TargetApi;
    value = 0x1d
.end annotation


# instance fields
.field private a:Lio/flutter/view/TextureRegistry$SurfaceProducer;


# direct methods
.method public constructor <init>(Lio/flutter/view/TextureRegistry$SurfaceProducer;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lio/flutter/plugin/platform/x;->a:Lio/flutter/view/TextureRegistry$SurfaceProducer;

    return-void
.end method


# virtual methods
.method public a(II)V
    .locals 1

    iget-object v0, p0, Lio/flutter/plugin/platform/x;->a:Lio/flutter/view/TextureRegistry$SurfaceProducer;

    invoke-interface {v0, p1, p2}, Lio/flutter/view/TextureRegistry$SurfaceProducer;->setSize(II)V

    return-void
.end method

.method public b()J
    .locals 2

    iget-object v0, p0, Lio/flutter/plugin/platform/x;->a:Lio/flutter/view/TextureRegistry$SurfaceProducer;

    invoke-interface {v0}, Lio/flutter/view/TextureRegistry$SurfaceProducer;->id()J

    move-result-wide v0

    return-wide v0
.end method

.method public getHeight()I
    .locals 1

    iget-object v0, p0, Lio/flutter/plugin/platform/x;->a:Lio/flutter/view/TextureRegistry$SurfaceProducer;

    invoke-interface {v0}, Lio/flutter/view/TextureRegistry$SurfaceProducer;->getHeight()I

    move-result v0

    return v0
.end method

.method public getSurface()Landroid/view/Surface;
    .locals 1

    iget-object v0, p0, Lio/flutter/plugin/platform/x;->a:Lio/flutter/view/TextureRegistry$SurfaceProducer;

    invoke-interface {v0}, Lio/flutter/view/TextureRegistry$SurfaceProducer;->getSurface()Landroid/view/Surface;

    move-result-object v0

    return-object v0
.end method

.method public getWidth()I
    .locals 1

    iget-object v0, p0, Lio/flutter/plugin/platform/x;->a:Lio/flutter/view/TextureRegistry$SurfaceProducer;

    invoke-interface {v0}, Lio/flutter/view/TextureRegistry$SurfaceProducer;->getWidth()I

    move-result v0

    return v0
.end method

.method public lockHardwareCanvas()Landroid/graphics/Canvas;
    .locals 1

    iget-object v0, p0, Lio/flutter/plugin/platform/x;->a:Lio/flutter/view/TextureRegistry$SurfaceProducer;

    invoke-interface {v0}, Lio/flutter/view/TextureRegistry$SurfaceProducer;->getSurface()Landroid/view/Surface;

    move-result-object v0

    invoke-static {v0}, Lio/flutter/plugin/platform/b;->a(Landroid/view/Surface;)Landroid/graphics/Canvas;

    move-result-object v0

    return-object v0
.end method

.method public release()V
    .locals 1

    iget-object v0, p0, Lio/flutter/plugin/platform/x;->a:Lio/flutter/view/TextureRegistry$SurfaceProducer;

    invoke-interface {v0}, Lio/flutter/view/TextureRegistry$SurfaceProducer;->release()V

    const/4 v0, 0x0

    iput-object v0, p0, Lio/flutter/plugin/platform/x;->a:Lio/flutter/view/TextureRegistry$SurfaceProducer;

    return-void
.end method

.method public unlockCanvasAndPost(Landroid/graphics/Canvas;)V
    .locals 1

    iget-object v0, p0, Lio/flutter/plugin/platform/x;->a:Lio/flutter/view/TextureRegistry$SurfaceProducer;

    invoke-interface {v0}, Lio/flutter/view/TextureRegistry$SurfaceProducer;->getSurface()Landroid/view/Surface;

    move-result-object v0

    invoke-virtual {v0, p1}, Landroid/view/Surface;->unlockCanvasAndPost(Landroid/graphics/Canvas;)V

    return-void
.end method
