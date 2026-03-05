.class Ln/b;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ln/c;


# instance fields
.field final a:Lcom/amap/api/maps/model/PolygonOptions;


# direct methods
.method constructor <init>()V
    .locals 2

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    new-instance v0, Lcom/amap/api/maps/model/PolygonOptions;

    invoke-direct {v0}, Lcom/amap/api/maps/model/PolygonOptions;-><init>()V

    iput-object v0, p0, Ln/b;->a:Lcom/amap/api/maps/model/PolygonOptions;

    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Lcom/amap/api/maps/model/PolygonOptions;->usePolylineStroke(Z)Lcom/amap/api/maps/model/PolygonOptions;

    return-void
.end method


# virtual methods
.method public a()Lcom/amap/api/maps/model/PolygonOptions;
    .locals 1

    iget-object v0, p0, Ln/b;->a:Lcom/amap/api/maps/model/PolygonOptions;

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

    iget-object v0, p0, Ln/b;->a:Lcom/amap/api/maps/model/PolygonOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolygonOptions;->setPoints(Ljava/util/List;)V

    return-void
.end method

.method public c(I)V
    .locals 1

    iget-object v0, p0, Ln/b;->a:Lcom/amap/api/maps/model/PolygonOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolygonOptions;->strokeColor(I)Lcom/amap/api/maps/model/PolygonOptions;

    return-void
.end method

.method public d(Lcom/amap/api/maps/model/AMapPara$LineJoinType;)V
    .locals 1

    iget-object v0, p0, Ln/b;->a:Lcom/amap/api/maps/model/PolygonOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolygonOptions;->lineJoinType(Lcom/amap/api/maps/model/AMapPara$LineJoinType;)Lcom/amap/api/maps/model/PolygonOptions;

    return-void
.end method

.method public e(I)V
    .locals 1

    iget-object v0, p0, Ln/b;->a:Lcom/amap/api/maps/model/PolygonOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolygonOptions;->fillColor(I)Lcom/amap/api/maps/model/PolygonOptions;

    return-void
.end method

.method public f(F)V
    .locals 1

    iget-object v0, p0, Ln/b;->a:Lcom/amap/api/maps/model/PolygonOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolygonOptions;->strokeWidth(F)Lcom/amap/api/maps/model/PolygonOptions;

    return-void
.end method

.method public setVisible(Z)V
    .locals 1

    iget-object v0, p0, Ln/b;->a:Lcom/amap/api/maps/model/PolygonOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolygonOptions;->visible(Z)Lcom/amap/api/maps/model/PolygonOptions;

    return-void
.end method
