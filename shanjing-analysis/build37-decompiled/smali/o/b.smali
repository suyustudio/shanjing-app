.class Lo/b;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lo/c;


# instance fields
.field final a:Lcom/amap/api/maps/model/PolylineOptions;


# direct methods
.method constructor <init>()V
    .locals 1

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    new-instance v0, Lcom/amap/api/maps/model/PolylineOptions;

    invoke-direct {v0}, Lcom/amap/api/maps/model/PolylineOptions;-><init>()V

    iput-object v0, p0, Lo/b;->a:Lcom/amap/api/maps/model/PolylineOptions;

    return-void
.end method


# virtual methods
.method public a(F)V
    .locals 1

    iget-object v0, p0, Lo/b;->a:Lcom/amap/api/maps/model/PolylineOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolylineOptions;->transparency(F)Lcom/amap/api/maps/model/PolylineOptions;

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

    iget-object v0, p0, Lo/b;->a:Lcom/amap/api/maps/model/PolylineOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolylineOptions;->setPoints(Ljava/util/List;)V

    return-void
.end method

.method public c(Lcom/amap/api/maps/model/PolylineOptions$LineCapType;)V
    .locals 1

    iget-object v0, p0, Lo/b;->a:Lcom/amap/api/maps/model/PolylineOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolylineOptions;->lineCapType(Lcom/amap/api/maps/model/PolylineOptions$LineCapType;)Lcom/amap/api/maps/model/PolylineOptions;

    return-void
.end method

.method public d(F)V
    .locals 1

    iget-object v0, p0, Lo/b;->a:Lcom/amap/api/maps/model/PolylineOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolylineOptions;->width(F)Lcom/amap/api/maps/model/PolylineOptions;

    return-void
.end method

.method public e(Lcom/amap/api/maps/model/PolylineOptions$LineJoinType;)V
    .locals 1

    iget-object v0, p0, Lo/b;->a:Lcom/amap/api/maps/model/PolylineOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolylineOptions;->lineJoinType(Lcom/amap/api/maps/model/PolylineOptions$LineJoinType;)Lcom/amap/api/maps/model/PolylineOptions;

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

    iget-object v0, p0, Lo/b;->a:Lcom/amap/api/maps/model/PolylineOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolylineOptions;->colorValues(Ljava/util/List;)Lcom/amap/api/maps/model/PolylineOptions;

    return-void
.end method

.method public g(Z)V
    .locals 1

    iget-object v0, p0, Lo/b;->a:Lcom/amap/api/maps/model/PolylineOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolylineOptions;->setDottedLine(Z)Lcom/amap/api/maps/model/PolylineOptions;

    return-void
.end method

.method public h(Z)V
    .locals 1

    iget-object v0, p0, Lo/b;->a:Lcom/amap/api/maps/model/PolylineOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolylineOptions;->geodesic(Z)Lcom/amap/api/maps/model/PolylineOptions;

    return-void
.end method

.method public i(I)V
    .locals 1

    iget-object v0, p0, Lo/b;->a:Lcom/amap/api/maps/model/PolylineOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolylineOptions;->color(I)Lcom/amap/api/maps/model/PolylineOptions;

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

    iget-object v0, p0, Lo/b;->a:Lcom/amap/api/maps/model/PolylineOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolylineOptions;->setCustomTextureList(Ljava/util/List;)Lcom/amap/api/maps/model/PolylineOptions;

    return-void
.end method

.method public k(Lcom/amap/api/maps/model/BitmapDescriptor;)V
    .locals 1

    iget-object v0, p0, Lo/b;->a:Lcom/amap/api/maps/model/PolylineOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolylineOptions;->setCustomTexture(Lcom/amap/api/maps/model/BitmapDescriptor;)Lcom/amap/api/maps/model/PolylineOptions;

    return-void
.end method

.method public l(I)V
    .locals 1

    iget-object v0, p0, Lo/b;->a:Lcom/amap/api/maps/model/PolylineOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolylineOptions;->setDottedLineType(I)Lcom/amap/api/maps/model/PolylineOptions;

    return-void
.end method

.method public m(Z)V
    .locals 1

    iget-object v0, p0, Lo/b;->a:Lcom/amap/api/maps/model/PolylineOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolylineOptions;->useGradient(Z)Lcom/amap/api/maps/model/PolylineOptions;

    return-void
.end method

.method public n()Lcom/amap/api/maps/model/PolylineOptions;
    .locals 1

    iget-object v0, p0, Lo/b;->a:Lcom/amap/api/maps/model/PolylineOptions;

    return-object v0
.end method

.method public setVisible(Z)V
    .locals 1

    iget-object v0, p0, Lo/b;->a:Lcom/amap/api/maps/model/PolylineOptions;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/PolylineOptions;->visible(Z)Lcom/amap/api/maps/model/PolylineOptions;

    return-void
.end method
