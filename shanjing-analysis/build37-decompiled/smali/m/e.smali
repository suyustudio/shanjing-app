.class public Lm/e;
.super Ll/a;
.source "SourceFile"

# interfaces
.implements Lj/b;
.implements Lcom/amap/api/maps/AMap$OnMapClickListener;
.implements Lcom/amap/api/maps/AMap$OnMarkerClickListener;
.implements Lcom/amap/api/maps/AMap$OnMarkerDragListener;
.implements Lcom/amap/api/maps/AMap$OnPOIClickListener;


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ll/a<",
        "Lm/a;",
        ">;",
        "Lj/b;",
        "Lcom/amap/api/maps/AMap$OnMapClickListener;",
        "Lcom/amap/api/maps/AMap$OnMarkerClickListener;",
        "Lcom/amap/api/maps/AMap$OnMarkerDragListener;",
        "Lcom/amap/api/maps/AMap$OnPOIClickListener;"
    }
.end annotation


# direct methods
.method public constructor <init>(Lj0/k;Lcom/amap/api/maps/AMap;)V
    .locals 0

    invoke-direct {p0, p1, p2}, Ll/a;-><init>(Lj0/k;Lcom/amap/api/maps/AMap;)V

    invoke-virtual {p2, p0}, Lcom/amap/api/maps/AMap;->addOnMarkerClickListener(Lcom/amap/api/maps/AMap$OnMarkerClickListener;)V

    invoke-virtual {p2, p0}, Lcom/amap/api/maps/AMap;->addOnMarkerDragListener(Lcom/amap/api/maps/AMap$OnMarkerDragListener;)V

    invoke-virtual {p2, p0}, Lcom/amap/api/maps/AMap;->addOnMapClickListener(Lcom/amap/api/maps/AMap$OnMapClickListener;)V

    invoke-virtual {p2, p0}, Lcom/amap/api/maps/AMap;->addOnPOIClickListener(Lcom/amap/api/maps/AMap$OnPOIClickListener;)V

    return-void
.end method

.method private a(Ljava/lang/Object;)V
    .locals 3

    iget-object v0, p0, Ll/a;->d:Lcom/amap/api/maps/AMap;

    if-eqz v0, :cond_1

    new-instance v0, Lm/b;

    invoke-direct {v0}, Lm/b;-><init>()V

    invoke-static {p1, v0}, Lm/d;->b(Ljava/lang/Object;Lm/c;)Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v2

    if-nez v2, :cond_1

    invoke-virtual {v0}, Lm/b;->m()Lcom/amap/api/maps/model/MarkerOptions;

    move-result-object v0

    iget-object v2, p0, Ll/a;->d:Lcom/amap/api/maps/AMap;

    invoke-virtual {v2, v0}, Lcom/amap/api/maps/AMap;->addMarker(Lcom/amap/api/maps/model/MarkerOptions;)Lcom/amap/api/maps/model/Marker;

    move-result-object v0

    const-string v2, "clickable"

    invoke-static {p1, v2}, Lp/b;->d(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    if-eqz p1, :cond_0

    invoke-static {p1}, Lp/b;->k(Ljava/lang/Object;)Z

    move-result p1

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/model/Marker;->setClickable(Z)V

    :cond_0
    new-instance p1, Lm/a;

    invoke-direct {p1, v0}, Lm/a;-><init>(Lcom/amap/api/maps/model/Marker;)V

    iget-object v2, p0, Ll/a;->a:Ljava/util/Map;

    invoke-interface {v2, v1, p1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    iget-object p1, p0, Ll/a;->b:Ljava/util/Map;

    invoke-virtual {v0}, Lcom/amap/api/maps/model/Marker;->getId()Ljava/lang/String;

    move-result-object v0

    invoke-interface {p1, v0, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    :cond_1
    return-void
.end method

.method private e(Ljava/util/List;)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "Ljava/lang/Object;",
            ">;)V"
        }
    .end annotation

    if-nez p1, :cond_0

    return-void

    :cond_0
    invoke-interface {p1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object p1

    :cond_1
    :goto_0
    invoke-interface {p1}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_3

    invoke-interface {p1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    if-nez v0, :cond_2

    goto :goto_0

    :cond_2
    check-cast v0, Ljava/lang/String;

    iget-object v1, p0, Ll/a;->a:Ljava/util/Map;

    invoke-interface {v1, v0}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lm/a;

    if-eqz v0, :cond_1

    iget-object v1, p0, Ll/a;->b:Ljava/util/Map;

    invoke-virtual {v0}, Lm/a;->m()Ljava/lang/String;

    move-result-object v2

    invoke-interface {v1, v2}, Ljava/util/Map;->remove(Ljava/lang/Object;)Ljava/lang/Object;

    invoke-virtual {v0}, Lm/a;->n()V

    goto :goto_0

    :cond_3
    return-void
.end method

.method private g(Ljava/lang/Object;)V
    .locals 2

    const-string v0, "id"

    invoke-static {p1, v0}, Lp/b;->d(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    if-eqz v0, :cond_0

    iget-object v1, p0, Ll/a;->a:Ljava/util/Map;

    invoke-interface {v1, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lm/a;

    if-eqz v0, :cond_0

    invoke-static {p1, v0}, Lm/d;->b(Ljava/lang/Object;Lm/c;)Ljava/lang/String;

    :cond_0
    return-void
.end method

.method private h(Ljava/util/List;)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "Ljava/lang/Object;",
            ">;)V"
        }
    .end annotation

    if-eqz p1, :cond_0

    invoke-interface {p1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object p1

    :goto_0
    invoke-interface {p1}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_0

    invoke-interface {p1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    invoke-direct {p0, v0}, Lm/e;->g(Ljava/lang/Object;)V

    goto :goto_0

    :cond_0
    return-void
.end method


# virtual methods
.method public b(Ljava/util/List;)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "Ljava/lang/Object;",
            ">;)V"
        }
    .end annotation

    if-eqz p1, :cond_0

    invoke-interface {p1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object p1

    :goto_0
    invoke-interface {p1}, Ljava/util/Iterator;->hasNext()Z

    move-result v0

    if-eqz v0, :cond_0

    invoke-interface {p1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    invoke-direct {p0, v0}, Lm/e;->a(Ljava/lang/Object;)V

    goto :goto_0

    :cond_0
    return-void
.end method

.method public c()[Ljava/lang/String;
    .locals 1

    sget-object v0, Lp/a;->b:[Ljava/lang/String;

    return-object v0
.end method

.method public d(Lj0/j;Lj0/k$d;)V
    .locals 1

    if-nez p1, :cond_0

    return-void

    :cond_0
    const-string v0, "markersToAdd"

    invoke-virtual {p1, v0}, Lj0/j;->a(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/util/List;

    invoke-virtual {p0, v0}, Lm/e;->b(Ljava/util/List;)V

    const-string v0, "markersToChange"

    invoke-virtual {p1, v0}, Lj0/j;->a(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/util/List;

    invoke-direct {p0, v0}, Lm/e;->h(Ljava/util/List;)V

    const-string v0, "markerIdsToRemove"

    invoke-virtual {p1, v0}, Lj0/j;->a(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/util/List;

    invoke-direct {p0, p1}, Lm/e;->e(Ljava/util/List;)V

    const/4 p1, 0x0

    invoke-interface {p2, p1}, Lj0/k$d;->a(Ljava/lang/Object;)V

    return-void
.end method

.method public f(Lj0/j;Lj0/k$d;)V
    .locals 2

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "doMethodCall===>"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p1, Lj0/j;->a:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "MarkersController"

    invoke-static {v1, v0}, Lp/c;->b(Ljava/lang/String;Ljava/lang/String;)V

    iget-object v0, p1, Lj0/j;->a:Ljava/lang/String;

    invoke-virtual {v0}, Ljava/lang/String;->hashCode()I

    const-string v1, "markers#update"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_0

    goto :goto_0

    :cond_0
    invoke-virtual {p0, p1, p2}, Lm/e;->d(Lj0/j;Lj0/k$d;)V

    :goto_0
    return-void
.end method
