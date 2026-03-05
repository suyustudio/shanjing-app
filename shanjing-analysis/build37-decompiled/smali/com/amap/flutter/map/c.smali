.class Lcom/amap/flutter/map/c;
.super Lio/flutter/plugin/platform/l;
.source "SourceFile"


# instance fields
.field private final b:Lj0/c;

.field private final c:Lj/a;


# direct methods
.method constructor <init>(Lj0/c;Lj/a;)V
    .locals 1

    sget-object v0, Lj0/q;->a:Lj0/q;

    invoke-direct {p0, v0}, Lio/flutter/plugin/platform/l;-><init>(Lj0/i;)V

    iput-object p1, p0, Lcom/amap/flutter/map/c;->b:Lj0/c;

    iput-object p2, p0, Lcom/amap/flutter/map/c;->c:Lj/a;

    return-void
.end method


# virtual methods
.method public a(Landroid/content/Context;ILjava/lang/Object;)Lio/flutter/plugin/platform/k;
    .locals 12

    const-string v0, "debugMode"

    const-string v1, "apiKey"

    const-string v2, "polygonsToAdd"

    const-string v3, "polylinesToAdd"

    const-string v4, "markersToAdd"

    const-string v5, "initialCameraPosition"

    const-string v6, "privacyStatement"

    const-string v7, "AMapPlatformViewFactory"

    new-instance v8, Lcom/amap/flutter/map/b;

    invoke-direct {v8}, Lcom/amap/flutter/map/b;-><init>()V

    :try_start_0
    invoke-virtual {p1}, Landroid/content/Context;->getResources()Landroid/content/res/Resources;

    move-result-object v9

    invoke-virtual {v9}, Landroid/content/res/Resources;->getDisplayMetrics()Landroid/util/DisplayMetrics;

    move-result-object v9

    iget v9, v9, Landroid/util/DisplayMetrics;->density:F

    sput v9, Lp/b;->a:F

    move-object v9, p3

    check-cast v9, Ljava/util/Map;

    new-instance v10, Ljava/lang/StringBuilder;

    invoke-direct {v10}, Ljava/lang/StringBuilder;-><init>()V

    const-string v11, "create params==>"

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v10, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {v10}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v10

    invoke-static {v7, v10}, Lp/c;->b(Ljava/lang/String;Ljava/lang/String;)V

    invoke-interface {v9, v6}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v10

    if-eqz v10, :cond_0

    invoke-interface {v9, v6}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v6

    invoke-static {p1, v6}, Lp/b;->g(Landroid/content/Context;Ljava/lang/Object;)V

    :cond_0
    check-cast p3, Ljava/util/Map;

    const-string v6, "options"

    invoke-interface {p3, v6}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p3

    if-eqz p3, :cond_1

    invoke-static {p3, v8}, Lp/b;->e(Ljava/lang/Object;Lk/a;)V

    :cond_1
    invoke-interface {v9, v5}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result p3

    if-eqz p3, :cond_2

    invoke-interface {v9, v5}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p3

    invoke-static {p3}, Lp/b;->l(Ljava/lang/Object;)Lcom/amap/api/maps/model/CameraPosition;

    move-result-object p3

    invoke-virtual {v8, p3}, Lcom/amap/flutter/map/b;->s(Lcom/amap/api/maps/model/CameraPosition;)V

    :cond_2
    invoke-interface {v9, v4}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result p3

    if-eqz p3, :cond_3

    invoke-interface {v9, v4}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p3

    invoke-virtual {v8, p3}, Lcom/amap/flutter/map/b;->t(Ljava/lang/Object;)V

    :cond_3
    invoke-interface {v9, v3}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result p3

    if-eqz p3, :cond_4

    invoke-interface {v9, v3}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p3

    invoke-virtual {v8, p3}, Lcom/amap/flutter/map/b;->v(Ljava/lang/Object;)V

    :cond_4
    invoke-interface {v9, v2}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result p3

    if-eqz p3, :cond_5

    invoke-interface {v9, v2}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p3

    invoke-virtual {v8, p3}, Lcom/amap/flutter/map/b;->u(Ljava/lang/Object;)V

    :cond_5
    invoke-interface {v9, v1}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result p3

    if-eqz p3, :cond_6

    invoke-interface {v9, v1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p3

    invoke-static {p3}, Lp/b;->b(Ljava/lang/Object;)V

    :cond_6
    invoke-interface {v9, v0}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result p3

    if-eqz p3, :cond_7

    invoke-interface {v9, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p3

    invoke-static {p3}, Lp/b;->k(Ljava/lang/Object;)Z

    move-result p3

    sput-boolean p3, Lp/c;->a:Z
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    move-exception p3

    const-string v0, "create"

    invoke-static {v7, v0, p3}, Lp/c;->a(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    :cond_7
    :goto_0
    iget-object p3, p0, Lcom/amap/flutter/map/c;->b:Lj0/c;

    iget-object v0, p0, Lcom/amap/flutter/map/c;->c:Lj/a;

    invoke-virtual {v8, p2, p1, p3, v0}, Lcom/amap/flutter/map/b;->f(ILandroid/content/Context;Lj0/c;Lj/a;)Lcom/amap/flutter/map/AMapPlatformView;

    move-result-object p1

    return-object p1
.end method
