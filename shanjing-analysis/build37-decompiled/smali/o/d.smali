.class Lo/d;
.super Ljava/lang/Object;
.source "SourceFile"


# static fields
.field private static final a:[I


# direct methods
.method static constructor <clinit>()V
    .locals 1

    const/4 v0, 0x3

    new-array v0, v0, [I

    fill-array-data v0, :array_0

    sput-object v0, Lo/d;->a:[I

    return-void

    nop

    :array_0
    .array-data 4
        -0x1
        0x0
        0x1
    .end array-data
.end method

.method static a(Ljava/lang/Object;Lo/c;)Ljava/lang/String;
    .locals 5

    invoke-static {p0}, Lp/b;->w(Ljava/lang/Object;)Ljava/util/Map;

    move-result-object p0

    const-string v0, "points"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_0

    invoke-static {v0}, Lp/b;->A(Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    invoke-interface {p1, v0}, Lo/c;->b(Ljava/util/List;)V

    :cond_0
    const-string v0, "width"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_1

    invoke-static {v0}, Lp/b;->p(Ljava/lang/Object;)F

    move-result v0

    invoke-interface {p1, v0}, Lo/c;->d(F)V

    :cond_1
    const-string v0, "visible"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_2

    invoke-static {v0}, Lp/b;->k(Ljava/lang/Object;)Z

    move-result v0

    invoke-interface {p1, v0}, Lo/c;->setVisible(Z)V

    :cond_2
    const-string v0, "geodesic"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_3

    invoke-static {v0}, Lp/b;->k(Ljava/lang/Object;)Z

    move-result v0

    invoke-interface {p1, v0}, Lo/c;->h(Z)V

    :cond_3
    const-string v0, "gradient"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_4

    invoke-static {v0}, Lp/b;->k(Ljava/lang/Object;)Z

    move-result v0

    invoke-interface {p1, v0}, Lo/c;->m(Z)V

    :cond_4
    const-string v0, "alpha"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_5

    invoke-static {v0}, Lp/b;->o(Ljava/lang/Object;)F

    move-result v0

    invoke-interface {p1, v0}, Lo/c;->a(F)V

    :cond_5
    const-string v0, "dashLineType"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_8

    invoke-static {v0}, Lp/b;->r(Ljava/lang/Object;)I

    move-result v0

    sget-object v1, Lo/d;->a:[I

    array-length v2, v1

    const/4 v3, 0x0

    if-le v0, v2, :cond_6

    const/4 v0, 0x0

    :cond_6
    aget v2, v1, v0

    const/4 v4, -0x1

    if-ne v2, v4, :cond_7

    invoke-interface {p1, v3}, Lo/c;->g(Z)V

    goto :goto_0

    :cond_7
    const/4 v2, 0x1

    invoke-interface {p1, v2}, Lo/c;->g(Z)V

    aget v0, v1, v0

    invoke-interface {p1, v0}, Lo/c;->l(I)V

    :cond_8
    :goto_0
    const-string v0, "capType"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_9

    invoke-static {v0}, Lp/b;->r(Ljava/lang/Object;)I

    move-result v0

    invoke-static {v0}, Lcom/amap/api/maps/model/PolylineOptions$LineCapType;->valueOf(I)Lcom/amap/api/maps/model/PolylineOptions$LineCapType;

    move-result-object v0

    invoke-interface {p1, v0}, Lo/c;->c(Lcom/amap/api/maps/model/PolylineOptions$LineCapType;)V

    :cond_9
    const-string v0, "joinType"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_a

    invoke-static {v0}, Lp/b;->r(Ljava/lang/Object;)I

    move-result v0

    invoke-static {v0}, Lcom/amap/api/maps/model/PolylineOptions$LineJoinType;->valueOf(I)Lcom/amap/api/maps/model/PolylineOptions$LineJoinType;

    move-result-object v0

    invoke-interface {p1, v0}, Lo/c;->e(Lcom/amap/api/maps/model/PolylineOptions$LineJoinType;)V

    :cond_a
    const-string v0, "customTexture"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_b

    invoke-static {v0}, Lp/b;->i(Ljava/lang/Object;)Lcom/amap/api/maps/model/BitmapDescriptor;

    move-result-object v0

    invoke-interface {p1, v0}, Lo/c;->k(Lcom/amap/api/maps/model/BitmapDescriptor;)V

    :cond_b
    const-string v0, "customTextureList"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_c

    invoke-static {v0}, Lp/b;->j(Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    invoke-interface {p1, v0}, Lo/c;->j(Ljava/util/List;)V

    :cond_c
    const-string v0, "color"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_d

    invoke-static {v0}, Lp/b;->r(Ljava/lang/Object;)I

    move-result v0

    invoke-interface {p1, v0}, Lo/c;->i(I)V

    :cond_d
    const-string v0, "colorList"

    invoke-interface {p0, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_e

    invoke-static {v0}, Lp/b;->u(Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    invoke-interface {p1, v0}, Lo/c;->f(Ljava/util/List;)V

    :cond_e
    const-string p1, "id"

    invoke-interface {p0, p1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/String;

    invoke-static {p0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result p1

    if-eqz p1, :cond_f

    const-string p1, "PolylineUtil"

    const-string v0, "\u6ca1\u6709\u4f20\u5165\u6b63\u786e\u7684dart\u5c42ID, \u8bf7\u786e\u8ba4\u5bf9\u5e94\u7684key\u503c\u662f\u5426\u6b63\u786e\uff01\uff01\uff01"

    invoke-static {p1, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    :cond_f
    return-object p0
.end method
