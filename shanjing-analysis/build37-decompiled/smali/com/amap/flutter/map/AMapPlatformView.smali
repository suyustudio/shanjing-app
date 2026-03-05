.class public Lcom/amap/flutter/map/AMapPlatformView;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Landroidx/lifecycle/DefaultLifecycleObserver;
.implements Lc0/c$a;
.implements Lj0/k$c;
.implements Lio/flutter/plugin/platform/k;


# instance fields
.field private final a:Lj0/k;

.field private b:Lk/b;

.field private c:Lm/e;

.field private d:Lo/e;

.field private e:Ln/e;

.field private f:Lcom/amap/api/maps/TextureMapView;

.field private g:Z

.field private final h:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Lj/b;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method constructor <init>(ILandroid/content/Context;Lj0/c;Lj/a;Lcom/amap/api/maps/AMapOptions;)V
    .locals 3

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/amap/flutter/map/AMapPlatformView;->g:Z

    new-instance v0, Lj0/k;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "amap_flutter_map_"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {v0, p3, p1}, Lj0/k;-><init>(Lj0/c;Ljava/lang/String;)V

    iput-object v0, p0, Lcom/amap/flutter/map/AMapPlatformView;->a:Lj0/k;

    invoke-virtual {v0, p0}, Lj0/k;->e(Lj0/k$c;)V

    new-instance p1, Ljava/util/HashMap;

    const/16 p3, 0x8

    invoke-direct {p1, p3}, Ljava/util/HashMap;-><init>(I)V

    iput-object p1, p0, Lcom/amap/flutter/map/AMapPlatformView;->h:Ljava/util/Map;

    :try_start_0
    new-instance p1, Lcom/amap/api/maps/TextureMapView;

    invoke-direct {p1, p2, p5}, Lcom/amap/api/maps/TextureMapView;-><init>(Landroid/content/Context;Lcom/amap/api/maps/AMapOptions;)V

    iput-object p1, p0, Lcom/amap/flutter/map/AMapPlatformView;->f:Lcom/amap/api/maps/TextureMapView;

    invoke-virtual {p1}, Lcom/amap/api/maps/TextureMapView;->getMap()Lcom/amap/api/maps/AMap;

    move-result-object p1

    new-instance p2, Lk/b;

    iget-object p3, p0, Lcom/amap/flutter/map/AMapPlatformView;->f:Lcom/amap/api/maps/TextureMapView;

    invoke-direct {p2, v0, p3}, Lk/b;-><init>(Lj0/k;Lcom/amap/api/maps/TextureMapView;)V

    iput-object p2, p0, Lcom/amap/flutter/map/AMapPlatformView;->b:Lk/b;

    new-instance p2, Lm/e;

    invoke-direct {p2, v0, p1}, Lm/e;-><init>(Lj0/k;Lcom/amap/api/maps/AMap;)V

    iput-object p2, p0, Lcom/amap/flutter/map/AMapPlatformView;->c:Lm/e;

    new-instance p2, Lo/e;

    invoke-direct {p2, v0, p1}, Lo/e;-><init>(Lj0/k;Lcom/amap/api/maps/AMap;)V

    iput-object p2, p0, Lcom/amap/flutter/map/AMapPlatformView;->d:Lo/e;

    new-instance p2, Ln/e;

    invoke-direct {p2, v0, p1}, Ln/e;-><init>(Lj0/k;Lcom/amap/api/maps/AMap;)V

    iput-object p2, p0, Lcom/amap/flutter/map/AMapPlatformView;->e:Ln/e;

    invoke-direct {p0}, Lcom/amap/flutter/map/AMapPlatformView;->v()V

    invoke-interface {p4}, Lj/a;->a()Landroidx/lifecycle/d;

    move-result-object p1

    invoke-virtual {p1, p0}, Landroidx/lifecycle/d;->a(Landroidx/lifecycle/f;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    move-exception p1

    const-string p2, "AMapPlatformView"

    const-string p3, "<init>"

    invoke-static {p2, p3, p1}, Lp/c;->a(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    :goto_0
    return-void
.end method

.method private q()V
    .locals 1

    iget-object v0, p0, Lcom/amap/flutter/map/AMapPlatformView;->f:Lcom/amap/api/maps/TextureMapView;

    if-nez v0, :cond_0

    return-void

    :cond_0
    invoke-virtual {v0}, Lcom/amap/api/maps/TextureMapView;->onDestroy()V

    return-void
.end method

.method private v()V
    .locals 7

    iget-object v0, p0, Lcom/amap/flutter/map/AMapPlatformView;->b:Lk/b;

    invoke-virtual {v0}, Lk/b;->t()[Ljava/lang/String;

    move-result-object v0

    const/4 v1, 0x0

    if-eqz v0, :cond_0

    array-length v2, v0

    if-lez v2, :cond_0

    array-length v2, v0

    const/4 v3, 0x0

    :goto_0
    if-ge v3, v2, :cond_0

    aget-object v4, v0, v3

    iget-object v5, p0, Lcom/amap/flutter/map/AMapPlatformView;->h:Ljava/util/Map;

    iget-object v6, p0, Lcom/amap/flutter/map/AMapPlatformView;->b:Lk/b;

    invoke-interface {v5, v4, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    add-int/lit8 v3, v3, 0x1

    goto :goto_0

    :cond_0
    iget-object v0, p0, Lcom/amap/flutter/map/AMapPlatformView;->c:Lm/e;

    invoke-virtual {v0}, Lm/e;->c()[Ljava/lang/String;

    move-result-object v0

    if-eqz v0, :cond_1

    array-length v2, v0

    if-lez v2, :cond_1

    array-length v2, v0

    const/4 v3, 0x0

    :goto_1
    if-ge v3, v2, :cond_1

    aget-object v4, v0, v3

    iget-object v5, p0, Lcom/amap/flutter/map/AMapPlatformView;->h:Ljava/util/Map;

    iget-object v6, p0, Lcom/amap/flutter/map/AMapPlatformView;->c:Lm/e;

    invoke-interface {v5, v4, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    add-int/lit8 v3, v3, 0x1

    goto :goto_1

    :cond_1
    iget-object v0, p0, Lcom/amap/flutter/map/AMapPlatformView;->d:Lo/e;

    invoke-virtual {v0}, Lo/e;->c()[Ljava/lang/String;

    move-result-object v0

    if-eqz v0, :cond_2

    array-length v2, v0

    if-lez v2, :cond_2

    array-length v2, v0

    const/4 v3, 0x0

    :goto_2
    if-ge v3, v2, :cond_2

    aget-object v4, v0, v3

    iget-object v5, p0, Lcom/amap/flutter/map/AMapPlatformView;->h:Ljava/util/Map;

    iget-object v6, p0, Lcom/amap/flutter/map/AMapPlatformView;->d:Lo/e;

    invoke-interface {v5, v4, v6}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    add-int/lit8 v3, v3, 0x1

    goto :goto_2

    :cond_2
    iget-object v0, p0, Lcom/amap/flutter/map/AMapPlatformView;->e:Ln/e;

    invoke-virtual {v0}, Ln/e;->c()[Ljava/lang/String;

    move-result-object v0

    if-eqz v0, :cond_3

    array-length v2, v0

    if-lez v2, :cond_3

    array-length v2, v0

    :goto_3
    if-ge v1, v2, :cond_3

    aget-object v3, v0, v1

    iget-object v4, p0, Lcom/amap/flutter/map/AMapPlatformView;->h:Ljava/util/Map;

    iget-object v5, p0, Lcom/amap/flutter/map/AMapPlatformView;->e:Ln/e;

    invoke-interface {v4, v3, v5}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    add-int/lit8 v1, v1, 0x1

    goto :goto_3

    :cond_3
    return-void
.end method


# virtual methods
.method public a()V
    .locals 3

    const-string v0, "AMapPlatformView"

    const-string v1, "dispose==>"

    invoke-static {v0, v1}, Lp/c;->b(Ljava/lang/String;Ljava/lang/String;)V

    :try_start_0
    iget-boolean v1, p0, Lcom/amap/flutter/map/AMapPlatformView;->g:Z

    if-eqz v1, :cond_0

    return-void

    :cond_0
    iget-object v1, p0, Lcom/amap/flutter/map/AMapPlatformView;->a:Lj0/k;

    const/4 v2, 0x0

    invoke-virtual {v1, v2}, Lj0/k;->e(Lj0/k$c;)V

    invoke-direct {p0}, Lcom/amap/flutter/map/AMapPlatformView;->q()V

    const/4 v1, 0x1

    iput-boolean v1, p0, Lcom/amap/flutter/map/AMapPlatformView;->g:Z
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    move-exception v1

    const-string v2, "dispose"

    invoke-static {v0, v2, v1}, Lp/c;->a(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    :goto_0
    return-void
.end method

.method public b(Landroidx/lifecycle/g;)V
    .locals 2

    const-string p1, "AMapPlatformView"

    const-string v0, "onResume==>"

    invoke-static {p1, v0}, Lp/c;->b(Ljava/lang/String;Ljava/lang/String;)V

    :try_start_0
    iget-boolean v0, p0, Lcom/amap/flutter/map/AMapPlatformView;->g:Z

    if-eqz v0, :cond_0

    return-void

    :cond_0
    iget-object v0, p0, Lcom/amap/flutter/map/AMapPlatformView;->f:Lcom/amap/api/maps/TextureMapView;

    if-eqz v0, :cond_1

    invoke-virtual {v0}, Lcom/amap/api/maps/TextureMapView;->onResume()V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    move-exception v0

    const-string v1, "onResume"

    invoke-static {p1, v1, v0}, Lp/c;->a(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    :cond_1
    :goto_0
    return-void
.end method

.method public c(Landroidx/lifecycle/g;)V
    .locals 2

    const-string p1, "AMapPlatformView"

    const-string v0, "onDestroy==>"

    invoke-static {p1, v0}, Lp/c;->b(Ljava/lang/String;Ljava/lang/String;)V

    :try_start_0
    iget-boolean v0, p0, Lcom/amap/flutter/map/AMapPlatformView;->g:Z

    if-eqz v0, :cond_0

    return-void

    :cond_0
    invoke-direct {p0}, Lcom/amap/flutter/map/AMapPlatformView;->q()V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    move-exception v0

    const-string v1, "onDestroy"

    invoke-static {p1, v1, v0}, Lp/c;->a(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    :goto_0
    return-void
.end method

.method public d(Landroid/os/Bundle;)V
    .locals 2

    const-string v0, "AMapPlatformView"

    const-string v1, "onDestroy==>"

    invoke-static {v0, v1}, Lp/c;->b(Ljava/lang/String;Ljava/lang/String;)V

    :try_start_0
    iget-boolean v1, p0, Lcom/amap/flutter/map/AMapPlatformView;->g:Z

    if-eqz v1, :cond_0

    return-void

    :cond_0
    iget-object v1, p0, Lcom/amap/flutter/map/AMapPlatformView;->f:Lcom/amap/api/maps/TextureMapView;

    invoke-virtual {v1, p1}, Lcom/amap/api/maps/TextureMapView;->onCreate(Landroid/os/Bundle;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    move-exception p1

    const-string v1, "onRestoreInstanceState"

    invoke-static {v0, v1, p1}, Lp/c;->a(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    :goto_0
    return-void
.end method

.method public e(Landroid/os/Bundle;)V
    .locals 2

    const-string v0, "AMapPlatformView"

    const-string v1, "onDestroy==>"

    invoke-static {v0, v1}, Lp/c;->b(Ljava/lang/String;Ljava/lang/String;)V

    :try_start_0
    iget-boolean v1, p0, Lcom/amap/flutter/map/AMapPlatformView;->g:Z

    if-eqz v1, :cond_0

    return-void

    :cond_0
    iget-object v1, p0, Lcom/amap/flutter/map/AMapPlatformView;->f:Lcom/amap/api/maps/TextureMapView;

    invoke-virtual {v1, p1}, Lcom/amap/api/maps/TextureMapView;->onSaveInstanceState(Landroid/os/Bundle;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    move-exception p1

    const-string v1, "onSaveInstanceState"

    invoke-static {v0, v1, p1}, Lp/c;->a(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    :goto_0
    return-void
.end method

.method public f(Landroidx/lifecycle/g;)V
    .locals 2

    const-string p1, "AMapPlatformView"

    const-string v0, "onCreate==>"

    invoke-static {p1, v0}, Lp/c;->b(Ljava/lang/String;Ljava/lang/String;)V

    :try_start_0
    iget-boolean v0, p0, Lcom/amap/flutter/map/AMapPlatformView;->g:Z

    if-eqz v0, :cond_0

    return-void

    :cond_0
    iget-object v0, p0, Lcom/amap/flutter/map/AMapPlatformView;->f:Lcom/amap/api/maps/TextureMapView;

    if-eqz v0, :cond_1

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Lcom/amap/api/maps/TextureMapView;->onCreate(Landroid/os/Bundle;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    move-exception v0

    const-string v1, "onCreate"

    invoke-static {p1, v1, v0}, Lp/c;->a(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    :cond_1
    :goto_0
    return-void
.end method

.method public h(Lj0/j;Lj0/k$d;)V
    .locals 3

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "onMethodCall==>"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p1, Lj0/j;->a:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v1, ", arguments==> "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p1, Lj0/j;->b:Ljava/lang/Object;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "AMapPlatformView"

    invoke-static {v1, v0}, Lp/c;->b(Ljava/lang/String;Ljava/lang/String;)V

    iget-object v0, p1, Lj0/j;->a:Ljava/lang/String;

    iget-object v2, p0, Lcom/amap/flutter/map/AMapPlatformView;->h:Ljava/util/Map;

    invoke-interface {v2, v0}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_0

    iget-object v1, p0, Lcom/amap/flutter/map/AMapPlatformView;->h:Ljava/util/Map;

    invoke-interface {v1, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lj/b;

    invoke-interface {v0, p1, p2}, Lj/b;->f(Lj0/j;Lj0/k$d;)V

    goto :goto_0

    :cond_0
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "onMethodCall, the methodId: "

    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object p1, p1, Lj0/j;->a:Ljava/lang/String;

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string p1, ", not implemented"

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v1, p1}, Lp/c;->c(Ljava/lang/String;Ljava/lang/String;)V

    invoke-interface {p2}, Lj0/k$d;->c()V

    :goto_0
    return-void
.end method

.method public synthetic i()V
    .locals 0

    invoke-static {p0}, Lio/flutter/plugin/platform/j;->d(Lio/flutter/plugin/platform/k;)V

    return-void
.end method

.method public j(Landroidx/lifecycle/g;)V
    .locals 2

    const-string p1, "AMapPlatformView"

    const-string v0, "onPause==>"

    invoke-static {p1, v0}, Lp/c;->b(Ljava/lang/String;Ljava/lang/String;)V

    :try_start_0
    iget-boolean v0, p0, Lcom/amap/flutter/map/AMapPlatformView;->g:Z

    if-eqz v0, :cond_0

    return-void

    :cond_0
    iget-object v0, p0, Lcom/amap/flutter/map/AMapPlatformView;->f:Lcom/amap/api/maps/TextureMapView;

    invoke-virtual {v0}, Lcom/amap/api/maps/TextureMapView;->onPause()V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    move-exception v0

    const-string v1, "onPause"

    invoke-static {p1, v1, v0}, Lp/c;->a(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    :goto_0
    return-void
.end method

.method public k(Landroidx/lifecycle/g;)V
    .locals 1

    const-string p1, "AMapPlatformView"

    const-string v0, "onStart==>"

    invoke-static {p1, v0}, Lp/c;->b(Ljava/lang/String;Ljava/lang/String;)V

    return-void
.end method

.method public l()Landroid/view/View;
    .locals 2

    const-string v0, "AMapPlatformView"

    const-string v1, "getView==>"

    invoke-static {v0, v1}, Lp/c;->b(Ljava/lang/String;Ljava/lang/String;)V

    iget-object v0, p0, Lcom/amap/flutter/map/AMapPlatformView;->f:Lcom/amap/api/maps/TextureMapView;

    return-object v0
.end method

.method public synthetic m(Landroid/view/View;)V
    .locals 0

    invoke-static {p0, p1}, Lio/flutter/plugin/platform/j;->a(Lio/flutter/plugin/platform/k;Landroid/view/View;)V

    return-void
.end method

.method public synthetic n()V
    .locals 0

    invoke-static {p0}, Lio/flutter/plugin/platform/j;->b(Lio/flutter/plugin/platform/k;)V

    return-void
.end method

.method public o(Landroidx/lifecycle/g;)V
    .locals 1

    const-string p1, "AMapPlatformView"

    const-string v0, "onStop==>"

    invoke-static {p1, v0}, Lp/c;->b(Ljava/lang/String;Ljava/lang/String;)V

    return-void
.end method

.method public synthetic p()V
    .locals 0

    invoke-static {p0}, Lio/flutter/plugin/platform/j;->c(Lio/flutter/plugin/platform/k;)V

    return-void
.end method

.method public r()Lk/b;
    .locals 1

    iget-object v0, p0, Lcom/amap/flutter/map/AMapPlatformView;->b:Lk/b;

    return-object v0
.end method

.method public s()Lm/e;
    .locals 1

    iget-object v0, p0, Lcom/amap/flutter/map/AMapPlatformView;->c:Lm/e;

    return-object v0
.end method

.method public t()Ln/e;
    .locals 1

    iget-object v0, p0, Lcom/amap/flutter/map/AMapPlatformView;->e:Ln/e;

    return-object v0
.end method

.method public u()Lo/e;
    .locals 1

    iget-object v0, p0, Lcom/amap/flutter/map/AMapPlatformView;->d:Lo/e;

    return-object v0
.end method
