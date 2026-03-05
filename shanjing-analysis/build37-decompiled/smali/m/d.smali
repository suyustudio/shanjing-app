.class public Lm/d;
.super Ljava/lang/Object;
.source "SourceFile"


# direct methods
.method private static a(Lm/c;Ljava/util/Map;)V
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lm/c;",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/Object;",
            ">;)V"
        }
    .end annotation

    const-string v0, "title"

    invoke-interface {p1, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;

    const-string v1, "snippet"

    invoke-interface {p1, v1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/String;

    invoke-static {v0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v1

    if-nez v1, :cond_0

    invoke-interface {p0, v0}, Lm/c;->i(Ljava/lang/String;)V

    :cond_0
    invoke-static {p1}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v0

    if-nez v0, :cond_1

    invoke-interface {p0, p1}, Lm/c;->g(Ljava/lang/String;)V

    :cond_1
    return-void
.end method

.method public static b(Ljava/lang/Object;Lm/c;)Ljava/lang/String;
    .locals 3

    if-nez p0, :cond_0

    const/4 p0, 0x0

    return-object p0

    :cond_0
    invoke-static {p0}, Lp/b;->w(Ljava/lang/Object;)Ljava/util/Map;

    move-result-object p0

    const-string v0, "alpha"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_1

    invoke-static {v0}, Lp/b;->o(Ljava/lang/Object;)F

    move-result v0

    invoke-interface {p1, v0}, Lm/c;->a(F)V

    :cond_1
    const-string v0, "anchor"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_2

    invoke-static {v0}, Lp/b;->u(Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    const/4 v1, 0x0

    invoke-interface {v0, v1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v1

    invoke-static {v1}, Lp/b;->o(Ljava/lang/Object;)F

    move-result v1

    const/4 v2, 0x1

    invoke-interface {v0, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    invoke-static {v0}, Lp/b;->o(Ljava/lang/Object;)F

    move-result v0

    invoke-interface {p1, v1, v0}, Lm/c;->f(FF)V

    :cond_2
    const-string v0, "consumeTapEvents"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    const-string v0, "draggable"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_3

    invoke-static {v0}, Lp/b;->k(Ljava/lang/Object;)Z

    move-result v0

    invoke-interface {p1, v0}, Lm/c;->b(Z)V

    :cond_3
    const-string v0, "flat"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_4

    invoke-static {v0}, Lp/b;->k(Ljava/lang/Object;)Z

    move-result v0

    invoke-interface {p1, v0}, Lm/c;->c(Z)V

    :cond_4
    const-string v0, "icon"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_5

    invoke-static {v0}, Lp/b;->i(Ljava/lang/Object;)Lcom/amap/api/maps/model/BitmapDescriptor;

    move-result-object v0

    invoke-interface {p1, v0}, Lm/c;->k(Lcom/amap/api/maps/model/BitmapDescriptor;)V

    :cond_5
    const-string v0, "infoWindow"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_6

    check-cast v0, Ljava/util/Map;

    invoke-static {p1, v0}, Lm/d;->a(Lm/c;Ljava/util/Map;)V

    :cond_6
    const-string v0, "position"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_7

    invoke-static {v0}, Lp/b;->s(Ljava/lang/Object;)Lcom/amap/api/maps/model/LatLng;

    move-result-object v0

    invoke-interface {p1, v0}, Lm/c;->j(Lcom/amap/api/maps/model/LatLng;)V

    :cond_7
    const-string v0, "rotation"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_8

    const/high16 v1, 0x43b40000    # 360.0f

    invoke-static {v0}, Lp/b;->o(Ljava/lang/Object;)F

    move-result v0

    sub-float/2addr v1, v0

    invoke-static {v1}, Ljava/lang/Math;->abs(F)F

    move-result v0

    invoke-interface {p1, v0}, Lm/c;->e(F)V

    :cond_8
    const-string v0, "visible"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_9

    invoke-static {v0}, Lp/b;->k(Ljava/lang/Object;)Z

    move-result v0

    invoke-interface {p1, v0}, Lm/c;->setVisible(Z)V

    :cond_9
    const-string v0, "zIndex"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_a

    invoke-static {v0}, Lp/b;->o(Ljava/lang/Object;)F

    move-result v0

    invoke-interface {p1, v0}, Lm/c;->h(F)V

    :cond_a
    const-string v0, "infoWindowEnable"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_b

    invoke-static {v0}, Lp/b;->k(Ljava/lang/Object;)Z

    move-result v0

    invoke-interface {p1, v0}, Lm/c;->l(Z)V

    :cond_b
    const-string v0, "clickable"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_c

    invoke-static {v0}, Lp/b;->k(Ljava/lang/Object;)Z

    move-result v0

    invoke-interface {p1, v0}, Lm/c;->d(Z)V

    :cond_c
    const-string p1, "id"

    invoke-interface {p0, p1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/String;

    if-eqz p0, :cond_d

    return-object p0

    :cond_d
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string p1, "markerId was null"

    invoke-direct {p0, p1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0
.end method
