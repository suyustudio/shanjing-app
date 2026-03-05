.class Lo/a;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lo/c;


# instance fields
.field final a:Lcom/amap/api/maps/model/Polyline;

.field final b:Ljava/lang/String;


# direct methods
.method constructor <init>(Lcom/amap/api/maps/model/Polyline;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lo/a;->a:Lcom/amap/api/maps/model/Polyline;

    invoke-virtual {p1}, Lcom/amap/api/maps/model/Polyline;->getId()Ljava/lang/String;

    move-result-object p1

    iput-object p1, p0, Lo/a;->b:Ljava/lang/String;

    return-void
.end method


# virtual methods
.method public a(F)V
    .locals 1

    iget-object v0, p0, Lo/a;->a:Lcom/amap/api/maps/model/Polyline;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Polyline;->setTransparency(F)V

    return-void
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

    iget-object v0, p0, Lo/a;->a:Lcom/amap/api/maps/model/Polyline;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Polyline;->setPoints(Ljava/util/List;)V

    return-void
.end method

.method public c(Lcom/amap/api/maps/model/PolylineOptions$LineCapType;)V
    .locals 1

    iget-object v0, p0, Lo/a;->a:Lcom/amap/api/maps/model/Polyline;

    invoke-virtual {v0}, Lcom/amap/api/maps/model/Polyline;->getOptions()Lcom/amap/api/maps/model/PolylineOptions;

    move-result-object v0

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolylineOptions;->lineCapType(Lcom/amap/api/maps/model/PolylineOptions$LineCapType;)Lcom/amap/api/maps/model/PolylineOptions;

    iget-object p1, p0, Lo/a;->a:Lcom/amap/api/maps/model/Polyline;

    invoke-virtual {p1, v0}, Lcom/amap/api/maps/model/Polyline;->setOptions(Lcom/amap/api/maps/model/PolylineOptions;)V

    return-void
.end method

.method public d(F)V
    .locals 1

    iget-object v0, p0, Lo/a;->a:Lcom/amap/api/maps/model/Polyline;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Polyline;->setWidth(F)V

    return-void
.end method

.method public e(Lcom/amap/api/maps/model/PolylineOptions$LineJoinType;)V
    .locals 1

    iget-object v0, p0, Lo/a;->a:Lcom/amap/api/maps/model/Polyline;

    invoke-virtual {v0}, Lcom/amap/api/maps/model/Polyline;->getOptions()Lcom/amap/api/maps/model/PolylineOptions;

    move-result-object v0

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolylineOptions;->lineJoinType(Lcom/amap/api/maps/model/PolylineOptions$LineJoinType;)Lcom/amap/api/maps/model/PolylineOptions;

    iget-object p1, p0, Lo/a;->a:Lcom/amap/api/maps/model/Polyline;

    invoke-virtual {p1, v0}, Lcom/amap/api/maps/model/Polyline;->setOptions(Lcom/amap/api/maps/model/PolylineOptions;)V

    return-void
.end method

.method public f(Ljava/util/List;)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "Ljava/lang/Integer;",
            ">;)V"
        }
    .end annotation

    iget-object v0, p0, Lo/a;->a:Lcom/amap/api/maps/model/Polyline;

    invoke-virtual {v0}, Lcom/amap/api/maps/model/Polyline;->getOptions()Lcom/amap/api/maps/model/PolylineOptions;

    move-result-object v0

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolylineOptions;->colorValues(Ljava/util/List;)Lcom/amap/api/maps/model/PolylineOptions;

    iget-object p1, p0, Lo/a;->a:Lcom/amap/api/maps/model/Polyline;

    invoke-virtual {p1, v0}, Lcom/amap/api/maps/model/Polyline;->setOptions(Lcom/amap/api/maps/model/PolylineOptions;)V

    return-void
.end method

.method public g(Z)V
    .locals 1

    iget-object v0, p0, Lo/a;->a:Lcom/amap/api/maps/model/Polyline;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Polyline;->setDottedLine(Z)V

    return-void
.end method

.method public h(Z)V
    .locals 1

    iget-object v0, p0, Lo/a;->a:Lcom/amap/api/maps/model/Polyline;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Polyline;->setGeodesic(Z)V

    return-void
.end method

.method public i(I)V
    .locals 1

    iget-object v0, p0, Lo/a;->a:Lcom/amap/api/maps/model/Polyline;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Polyline;->setColor(I)V

    return-void
.end method

.method public j(Ljava/util/List;)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "Lcom/amap/api/maps/model/BitmapDescriptor;",
            ">;)V"
        }
    .end annotation

    iget-object v0, p0, Lo/a;->a:Lcom/amap/api/maps/model/Polyline;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Polyline;->setCustomTextureList(Ljava/util/List;)V

    return-void
.end method

.method public k(Lcom/amap/api/maps/model/BitmapDescriptor;)V
    .locals 1

    iget-object v0, p0, Lo/a;->a:Lcom/amap/api/maps/model/Polyline;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Polyline;->setCustomTexture(Lcom/amap/api/maps/model/BitmapDescriptor;)V

    return-void
.end method

.method public l(I)V
    .locals 1

    iget-object v0, p0, Lo/a;->a:Lcom/amap/api/maps/model/Polyline;

    invoke-virtual {v0}, Lcom/amap/api/maps/model/Polyline;->getOptions()Lcom/amap/api/maps/model/PolylineOptions;

    move-result-object v0

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolylineOptions;->setDottedLineType(I)Lcom/amap/api/maps/model/PolylineOptions;

    iget-object p1, p0, Lo/a;->a:Lcom/amap/api/maps/model/Polyline;

    invoke-virtual {p1, v0}, Lcom/amap/api/maps/model/Polyline;->setOptions(Lcom/amap/api/maps/model/PolylineOptions;)V

    return-void
.end method

.method public m(Z)V
    .locals 1

    iget-object v0, p0, Lo/a;->a:Lcom/amap/api/maps/model/Polyline;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Polyline;->setGeodesic(Z)V

    return-void
.end method

.method public n()Ljava/lang/String;
    .locals 1

    iget-object v0, p0, Lo/a;->b:Ljava/lang/String;

    return-object v0
.end method

.method public o()V
    .locals 1

    iget-object v0, p0, Lo/a;->a:Lcom/amap/api/maps/model/Polyline;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Lcom/amap/api/maps/model/Polyline;->remove()V

    :cond_0
    return-void
.end method

.method public setVisible(Z)V
    .locals 1

    iget-object v0, p0, Lo/a;->a:Lcom/amap/api/maps/model/Polyline;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Polyline;->setVisible(Z)V

    return-void
.end method
