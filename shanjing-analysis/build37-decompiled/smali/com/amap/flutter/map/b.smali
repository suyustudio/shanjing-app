.class Lcom/amap/flutter/map/b;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lk/a;


# instance fields
.field private final a:Lcom/amap/api/maps/AMapOptions;

.field private b:Lcom/amap/api/maps/model/CustomMapStyleOptions;

.field private c:Lcom/amap/api/maps/model/MyLocationStyle;

.field private d:F

.field private e:F

.field private f:Lcom/amap/api/maps/model/LatLngBounds;

.field private g:Z

.field private h:Z

.field private i:Z

.field private j:Z

.field private k:F

.field private l:F

.field private m:Ljava/lang/Object;

.field private n:Ljava/lang/Object;

.field private o:Ljava/lang/Object;


# direct methods
.method constructor <init>()V
    .locals 1

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    new-instance v0, Lcom/amap/api/maps/AMapOptions;

    invoke-direct {v0}, Lcom/amap/api/maps/AMapOptions;-><init>()V

    iput-object v0, p0, Lcom/amap/flutter/map/b;->a:Lcom/amap/api/maps/AMapOptions;

    const/high16 v0, 0x40400000    # 3.0f

    iput v0, p0, Lcom/amap/flutter/map/b;->d:F

    const/high16 v0, 0x41a00000    # 20.0f

    iput v0, p0, Lcom/amap/flutter/map/b;->e:F

    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/amap/flutter/map/b;->g:Z

    iput-boolean v0, p0, Lcom/amap/flutter/map/b;->h:Z

    iput-boolean v0, p0, Lcom/amap/flutter/map/b;->i:Z

    iput-boolean v0, p0, Lcom/amap/flutter/map/b;->j:Z

    const/high16 v0, 0x40000000    # 2.0f

    iput v0, p0, Lcom/amap/flutter/map/b;->k:F

    iput v0, p0, Lcom/amap/flutter/map/b;->l:F

    return-void
.end method


# virtual methods
.method public a(I)V
    .locals 1

    iget-object v0, p0, Lcom/amap/flutter/map/b;->a:Lcom/amap/api/maps/AMapOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/AMapOptions;->mapType(I)Lcom/amap/api/maps/AMapOptions;

    return-void
.end method

.method public b(Z)V
    .locals 0

    iput-boolean p1, p0, Lcom/amap/flutter/map/b;->i:Z

    return-void
.end method

.method public c(Z)V
    .locals 1

    iget-object v0, p0, Lcom/amap/flutter/map/b;->a:Lcom/amap/api/maps/AMapOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/AMapOptions;->scaleControlsEnabled(Z)Lcom/amap/api/maps/AMapOptions;

    return-void
.end method

.method public d(Z)V
    .locals 1

    iget-object v0, p0, Lcom/amap/flutter/map/b;->a:Lcom/amap/api/maps/AMapOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/AMapOptions;->compassEnabled(Z)Lcom/amap/api/maps/AMapOptions;

    return-void
.end method

.method public e(Z)V
    .locals 0

    iput-boolean p1, p0, Lcom/amap/flutter/map/b;->h:Z

    return-void
.end method

.method f(ILandroid/content/Context;Lj0/c;Lj/a;)Lcom/amap/flutter/map/AMapPlatformView;
    .locals 8

    :try_start_0
    iget-object v0, p0, Lcom/amap/flutter/map/b;->a:Lcom/amap/api/maps/AMapOptions;

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Lcom/amap/api/maps/AMapOptions;->zoomControlsEnabled(Z)Lcom/amap/api/maps/AMapOptions;

    new-instance v0, Lcom/amap/flutter/map/AMapPlatformView;

    iget-object v7, p0, Lcom/amap/flutter/map/b;->a:Lcom/amap/api/maps/AMapOptions;

    move-object v2, v0

    move v3, p1

    move-object v4, p2

    move-object v5, p3

    move-object v6, p4

    invoke-direct/range {v2 .. v7}, Lcom/amap/flutter/map/AMapPlatformView;-><init>(ILandroid/content/Context;Lj0/c;Lj/a;Lcom/amap/api/maps/AMapOptions;)V

    iget-object p1, p0, Lcom/amap/flutter/map/b;->b:Lcom/amap/api/maps/model/CustomMapStyleOptions;

    if-eqz p1, :cond_0

    invoke-virtual {v0}, Lcom/amap/flutter/map/AMapPlatformView;->r()Lk/b;

    move-result-object p1

    iget-object p2, p0, Lcom/amap/flutter/map/b;->b:Lcom/amap/api/maps/model/CustomMapStyleOptions;

    invoke-virtual {p1, p2}, Lk/b;->j(Lcom/amap/api/maps/model/CustomMapStyleOptions;)V

    :cond_0
    iget-object p1, p0, Lcom/amap/flutter/map/b;->c:Lcom/amap/api/maps/model/MyLocationStyle;

    if-eqz p1, :cond_1

    invoke-virtual {v0}, Lcom/amap/flutter/map/AMapPlatformView;->r()Lk/b;

    move-result-object p1

    iget-object p2, p0, Lcom/amap/flutter/map/b;->c:Lcom/amap/api/maps/model/MyLocationStyle;

    invoke-virtual {p1, p2}, Lk/b;->i(Lcom/amap/api/maps/model/MyLocationStyle;)V

    :cond_1
    iget p1, p0, Lcom/amap/flutter/map/b;->k:F

    const/4 p2, 0x0

    cmpl-float p3, p1, p2

    if-ltz p3, :cond_2

    float-to-double p3, p1

    const-wide/high16 v1, 0x3ff0000000000000L    # 1.0

    cmpg-double p1, p3, v1

    if-gtz p1, :cond_2

    iget p1, p0, Lcom/amap/flutter/map/b;->l:F

    float-to-double p3, p1

    cmpg-double v3, p3, v1

    if-gtz v3, :cond_2

    cmpl-float p1, p1, p2

    if-ltz p1, :cond_2

    invoke-virtual {v0}, Lcom/amap/flutter/map/AMapPlatformView;->r()Lk/b;

    move-result-object p1

    iget p2, p0, Lcom/amap/flutter/map/b;->k:F

    iget p3, p0, Lcom/amap/flutter/map/b;->l:F

    invoke-virtual {p1, p2, p3}, Lk/b;->m(FF)V

    :cond_2
    invoke-virtual {v0}, Lcom/amap/flutter/map/AMapPlatformView;->r()Lk/b;

    move-result-object p1

    iget p2, p0, Lcom/amap/flutter/map/b;->d:F

    invoke-virtual {p1, p2}, Lk/b;->o(F)V

    invoke-virtual {v0}, Lcom/amap/flutter/map/AMapPlatformView;->r()Lk/b;

    move-result-object p1

    iget p2, p0, Lcom/amap/flutter/map/b;->e:F

    invoke-virtual {p1, p2}, Lk/b;->h(F)V

    iget-object p1, p0, Lcom/amap/flutter/map/b;->f:Lcom/amap/api/maps/model/LatLngBounds;

    if-eqz p1, :cond_3

    invoke-virtual {v0}, Lcom/amap/flutter/map/AMapPlatformView;->r()Lk/b;

    move-result-object p1

    iget-object p2, p0, Lcom/amap/flutter/map/b;->f:Lcom/amap/api/maps/model/LatLngBounds;

    invoke-virtual {p1, p2}, Lk/b;->q(Lcom/amap/api/maps/model/LatLngBounds;)V

    :cond_3
    invoke-virtual {v0}, Lcom/amap/flutter/map/AMapPlatformView;->r()Lk/b;

    move-result-object p1

    iget-boolean p2, p0, Lcom/amap/flutter/map/b;->g:Z

    invoke-virtual {p1, p2}, Lk/b;->p(Z)V

    invoke-virtual {v0}, Lcom/amap/flutter/map/AMapPlatformView;->r()Lk/b;

    move-result-object p1

    iget-boolean p2, p0, Lcom/amap/flutter/map/b;->h:Z

    invoke-virtual {p1, p2}, Lk/b;->e(Z)V

    invoke-virtual {v0}, Lcom/amap/flutter/map/AMapPlatformView;->r()Lk/b;

    move-result-object p1

    iget-boolean p2, p0, Lcom/amap/flutter/map/b;->i:Z

    invoke-virtual {p1, p2}, Lk/b;->b(Z)V

    invoke-virtual {v0}, Lcom/amap/flutter/map/AMapPlatformView;->r()Lk/b;

    move-result-object p1

    iget-boolean p2, p0, Lcom/amap/flutter/map/b;->j:Z

    invoke-virtual {p1, p2}, Lk/b;->k(Z)V

    iget-object p1, p0, Lcom/amap/flutter/map/b;->m:Ljava/lang/Object;

    if-eqz p1, :cond_4

    check-cast p1, Ljava/util/List;

    invoke-virtual {v0}, Lcom/amap/flutter/map/AMapPlatformView;->s()Lm/e;

    move-result-object p2

    invoke-virtual {p2, p1}, Lm/e;->b(Ljava/util/List;)V

    :cond_4
    iget-object p1, p0, Lcom/amap/flutter/map/b;->n:Ljava/lang/Object;

    if-eqz p1, :cond_5

    check-cast p1, Ljava/util/List;

    invoke-virtual {v0}, Lcom/amap/flutter/map/AMapPlatformView;->u()Lo/e;

    move-result-object p2

    invoke-virtual {p2, p1}, Lo/e;->a(Ljava/util/List;)V

    :cond_5
    iget-object p1, p0, Lcom/amap/flutter/map/b;->o:Ljava/lang/Object;

    if-eqz p1, :cond_6

    check-cast p1, Ljava/util/List;

    invoke-virtual {v0}, Lcom/amap/flutter/map/AMapPlatformView;->t()Ln/e;

    move-result-object p2

    invoke-virtual {p2, p1}, Ln/e;->b(Ljava/util/List;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    :cond_6
    return-object v0

    :catchall_0
    move-exception p1

    const-string p2, "AMapOptionsBuilder"

    const-string p3, "build"

    invoke-static {p2, p3, p1}, Lp/c;->a(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    const/4 p1, 0x0

    return-object p1
.end method

.method public g(Z)V
    .locals 1

    iget-object v0, p0, Lcom/amap/flutter/map/b;->a:Lcom/amap/api/maps/AMapOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/AMapOptions;->scrollGesturesEnabled(Z)Lcom/amap/api/maps/AMapOptions;

    return-void
.end method

.method public h(F)V
    .locals 0

    iput p1, p0, Lcom/amap/flutter/map/b;->e:F

    return-void
.end method

.method public i(Lcom/amap/api/maps/model/MyLocationStyle;)V
    .locals 0

    iput-object p1, p0, Lcom/amap/flutter/map/b;->c:Lcom/amap/api/maps/model/MyLocationStyle;

    return-void
.end method

.method public j(Lcom/amap/api/maps/model/CustomMapStyleOptions;)V
    .locals 0

    iput-object p1, p0, Lcom/amap/flutter/map/b;->b:Lcom/amap/api/maps/model/CustomMapStyleOptions;

    return-void
.end method

.method public k(Z)V
    .locals 0

    iput-boolean p1, p0, Lcom/amap/flutter/map/b;->j:Z

    return-void
.end method

.method public l(Z)V
    .locals 1

    iget-object v0, p0, Lcom/amap/flutter/map/b;->a:Lcom/amap/api/maps/AMapOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/AMapOptions;->tiltGesturesEnabled(Z)Lcom/amap/api/maps/AMapOptions;

    return-void
.end method

.method public m(FF)V
    .locals 0

    iput p1, p0, Lcom/amap/flutter/map/b;->k:F

    iput p2, p0, Lcom/amap/flutter/map/b;->l:F

    return-void
.end method

.method public n(Z)V
    .locals 1

    iget-object v0, p0, Lcom/amap/flutter/map/b;->a:Lcom/amap/api/maps/AMapOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/AMapOptions;->zoomGesturesEnabled(Z)Lcom/amap/api/maps/AMapOptions;

    return-void
.end method

.method public o(F)V
    .locals 0

    iput p1, p0, Lcom/amap/flutter/map/b;->d:F

    return-void
.end method

.method public p(Z)V
    .locals 0

    iput-boolean p1, p0, Lcom/amap/flutter/map/b;->g:Z

    return-void
.end method

.method public q(Lcom/amap/api/maps/model/LatLngBounds;)V
    .locals 0

    iput-object p1, p0, Lcom/amap/flutter/map/b;->f:Lcom/amap/api/maps/model/LatLngBounds;

    return-void
.end method

.method public r(Z)V
    .locals 1

    iget-object v0, p0, Lcom/amap/flutter/map/b;->a:Lcom/amap/api/maps/AMapOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/AMapOptions;->rotateGesturesEnabled(Z)Lcom/amap/api/maps/AMapOptions;

    return-void
.end method

.method public s(Lcom/amap/api/maps/model/CameraPosition;)V
    .locals 1

    iget-object v0, p0, Lcom/amap/flutter/map/b;->a:Lcom/amap/api/maps/AMapOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/AMapOptions;->camera(Lcom/amap/api/maps/model/CameraPosition;)Lcom/amap/api/maps/AMapOptions;

    return-void
.end method

.method public t(Ljava/lang/Object;)V
    .locals 0

    iput-object p1, p0, Lcom/amap/flutter/map/b;->m:Ljava/lang/Object;

    return-void
.end method

.method public u(Ljava/lang/Object;)V
    .locals 0

    iput-object p1, p0, Lcom/amap/flutter/map/b;->o:Ljava/lang/Object;

    return-void
.end method

.method public v(Ljava/lang/Object;)V
    .locals 0

    iput-object p1, p0, Lcom/amap/flutter/map/b;->n:Ljava/lang/Object;

    return-void
.end method
