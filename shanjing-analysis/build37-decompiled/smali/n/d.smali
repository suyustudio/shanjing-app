.class Ln/d;
.super Ljava/lang/Object;
.source "SourceFile"


# direct methods
.method static a(Ljava/lang/Object;Ln/c;)Ljava/lang/String;
    .locals 1

    invoke-static {p0}, Lp/b;->w(Ljava/lang/Object;)Ljava/util/Map;

    move-result-object p0

    const-string v0, "points"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_0

    invoke-static {v0}, Lp/b;->A(Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    invoke-interface {p1, v0}, Ln/c;->b(Ljava/util/List;)V

    :cond_0
    const-string v0, "strokeWidth"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_1

    invoke-static {v0}, Lp/b;->p(Ljava/lang/Object;)F

    move-result v0

    invoke-interface {p1, v0}, Ln/c;->f(F)V

    :cond_1
    const-string v0, "strokeColor"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_2

    invoke-static {v0}, Lp/b;->r(Ljava/lang/Object;)I

    move-result v0

    invoke-interface {p1, v0}, Ln/c;->c(I)V

    :cond_2
    const-string v0, "fillColor"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_3

    invoke-static {v0}, Lp/b;->r(Ljava/lang/Object;)I

    move-result v0

    invoke-interface {p1, v0}, Ln/c;->e(I)V

    :cond_3
    const-string v0, "visible"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_4

    invoke-static {v0}, Lp/b;->k(Ljava/lang/Object;)Z

    move-result v0

    invoke-interface {p1, v0}, Ln/c;->setVisible(Z)V

    :cond_4
    const-string v0, "joinType"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_5

    invoke-static {v0}, Lp/b;->r(Ljava/lang/Object;)I

    move-result v0

    invoke-static {v0}, Lcom/amap/api/maps/model/AMapPara$LineJoinType;->valueOf(I)Lcom/amap/api/maps/model/AMapPara$LineJoinType;

    move-result-object v0

    invoke-interface {p1, v0}, Ln/c;->d(Lcom/amap/api/maps/model/AMapPara$LineJoinType;)V

    :cond_5
    const-string p1, "id"

    invoke-interface {p0, p1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/String;

    if-eqz p0, :cond_6

    return-object p0

    :cond_6
    new-instance p0, Ljava/lang/IllegalArgumentException;

    const-string p1, "polylineId was null"

    invoke-direct {p0, p1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p0
.end method
