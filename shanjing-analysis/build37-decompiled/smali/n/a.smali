.class Ln/a;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ln/c;


# instance fields
.field private final a:Lcom/amap/api/maps/model/Polygon;

.field private final b:Ljava/lang/String;


# direct methods
.method constructor <init>(Lcom/amap/api/maps/model/Polygon;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Ln/a;->a:Lcom/amap/api/maps/model/Polygon;

    invoke-virtual {p1}, Lcom/amap/api/maps/model/Polygon;->getId()Ljava/lang/String;

    move-result-object p1

    iput-object p1, p0, Ln/a;->b:Ljava/lang/String;

    return-void
.end method


# virtual methods
.method public a()Ljava/lang/String;
    .locals 1

    iget-object v0, p0, Ln/a;->b:Ljava/lang/String;

    return-object v0
.end method

.method public b(Ljava/util/List;)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "Lcom/amap/api/maps/model/LatLng;",
            ">;)V"
        }
    .end annotation

    iget-object v0, p0, Ln/a;->a:Lcom/amap/api/maps/model/Polygon;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Polygon;->setPoints(Ljava/util/List;)V

    return-void
.end method

.method public c(I)V
    .locals 1

    iget-object v0, p0, Ln/a;->a:Lcom/amap/api/maps/model/Polygon;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Polygon;->setStrokeColor(I)V

    return-void
.end method

.method public d(Lcom/amap/api/maps/model/AMapPara$LineJoinType;)V
    .locals 0

    return-void
.end method

.method public e(I)V
    .locals 1

    iget-object v0, p0, Ln/a;->a:Lcom/amap/api/maps/model/Polygon;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Polygon;->setFillColor(I)V

    return-void
.end method

.method public f(F)V
    .locals 1

    iget-object v0, p0, Ln/a;->a:Lcom/amap/api/maps/model/Polygon;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Polygon;->setStrokeWidth(F)V

    return-void
.end method

.method public g()V
    .locals 1

    iget-object v0, p0, Ln/a;->a:Lcom/amap/api/maps/model/Polygon;

    invoke-virtual {v0}, Lcom/amap/api/maps/model/Polygon;->remove()V

    return-void
.end method

.method public setVisible(Z)V
    .locals 1

    iget-object v0, p0, Ln/a;->a:Lcom/amap/api/maps/model/Polygon;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Polygon;->setVisible(Z)V

    return-void
.end method
