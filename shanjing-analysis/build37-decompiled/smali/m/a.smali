.class Lm/a;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lm/c;


# instance fields
.field private final a:Lcom/amap/api/maps/model/Marker;

.field private final b:Ljava/lang/String;


# direct methods
.method constructor <init>(Lcom/amap/api/maps/model/Marker;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lm/a;->a:Lcom/amap/api/maps/model/Marker;

    invoke-virtual {p1}, Lcom/amap/api/maps/model/Marker;->getId()Ljava/lang/String;

    move-result-object p1

    iput-object p1, p0, Lm/a;->b:Ljava/lang/String;

    return-void
.end method


# virtual methods
.method public a(F)V
    .locals 1

    iget-object v0, p0, Lm/a;->a:Lcom/amap/api/maps/model/Marker;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Marker;->setAlpha(F)V

    return-void
.end method

.method public b(Z)V
    .locals 1

    iget-object v0, p0, Lm/a;->a:Lcom/amap/api/maps/model/Marker;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Marker;->setDraggable(Z)V

    return-void
.end method

.method public c(Z)V
    .locals 1

    iget-object v0, p0, Lm/a;->a:Lcom/amap/api/maps/model/Marker;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Marker;->setFlat(Z)V

    return-void
.end method

.method public d(Z)V
    .locals 1

    iget-object v0, p0, Lm/a;->a:Lcom/amap/api/maps/model/Marker;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Marker;->setClickable(Z)V

    return-void
.end method

.method public e(F)V
    .locals 1

    iget-object v0, p0, Lm/a;->a:Lcom/amap/api/maps/model/Marker;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Marker;->setRotateAngle(F)V

    return-void
.end method

.method public f(FF)V
    .locals 1

    iget-object v0, p0, Lm/a;->a:Lcom/amap/api/maps/model/Marker;

    invoke-virtual {v0, p1, p2}, Lcom/amap/api/maps/model/Marker;->setAnchor(FF)V

    return-void
.end method

.method public g(Ljava/lang/String;)V
    .locals 1

    iget-object v0, p0, Lm/a;->a:Lcom/amap/api/maps/model/Marker;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Marker;->setSnippet(Ljava/lang/String;)V

    return-void
.end method

.method public h(F)V
    .locals 1

    iget-object v0, p0, Lm/a;->a:Lcom/amap/api/maps/model/Marker;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Marker;->setZIndex(F)V

    return-void
.end method

.method public i(Ljava/lang/String;)V
    .locals 1

    iget-object v0, p0, Lm/a;->a:Lcom/amap/api/maps/model/Marker;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Marker;->setTitle(Ljava/lang/String;)V

    return-void
.end method

.method public j(Lcom/amap/api/maps/model/LatLng;)V
    .locals 1

    iget-object v0, p0, Lm/a;->a:Lcom/amap/api/maps/model/Marker;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Marker;->setPosition(Lcom/amap/api/maps/model/LatLng;)V

    return-void
.end method

.method public k(Lcom/amap/api/maps/model/BitmapDescriptor;)V
    .locals 1

    iget-object v0, p0, Lm/a;->a:Lcom/amap/api/maps/model/Marker;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Marker;->setIcon(Lcom/amap/api/maps/model/BitmapDescriptor;)V

    return-void
.end method

.method public l(Z)V
    .locals 1

    iget-object v0, p0, Lm/a;->a:Lcom/amap/api/maps/model/Marker;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Marker;->setInfoWindowEnable(Z)V

    return-void
.end method

.method public m()Ljava/lang/String;
    .locals 1

    iget-object v0, p0, Lm/a;->b:Ljava/lang/String;

    return-object v0
.end method

.method public n()V
    .locals 1

    iget-object v0, p0, Lm/a;->a:Lcom/amap/api/maps/model/Marker;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Lcom/amap/api/maps/model/Marker;->remove()V

    :cond_0
    return-void
.end method

.method public setVisible(Z)V
    .locals 1

    iget-object v0, p0, Lm/a;->a:Lcom/amap/api/maps/model/Marker;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Marker;->setVisible(Z)V

    return-void
.end method
