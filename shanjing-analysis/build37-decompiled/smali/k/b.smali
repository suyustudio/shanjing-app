.class public Lk/b;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lj/b;
.implements Lk/a;
.implements Lcom/amap/api/maps/AMap$OnMapLoadedListener;
.implements Lcom/amap/api/maps/AMap$OnMyLocationChangeListener;
.implements Lcom/amap/api/maps/AMap$OnCameraChangeListener;
.implements Lcom/amap/api/maps/AMap$OnMapClickListener;
.implements Lcom/amap/api/maps/AMap$OnMapLongClickListener;
.implements Lcom/amap/api/maps/AMap$OnPOIClickListener;


# instance fields
.field private final a:Lj0/k;

.field private final b:Lcom/amap/api/maps/AMap;

.field private final c:Lcom/amap/api/maps/TextureMapView;

.field private d:Lj0/k$d;

.field protected e:[I

.field private f:Z

.field private g:Z


# direct methods
.method static constructor <clinit>()V
    .locals 0

    return-void
.end method

.method public constructor <init>(Lj0/k;Lcom/amap/api/maps/TextureMapView;)V
    .locals 2

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    const/4 v0, 0x0

    new-array v1, v0, [I

    iput-object v1, p0, Lk/b;->e:[I

    iput-boolean v0, p0, Lk/b;->f:Z

    iput-boolean v0, p0, Lk/b;->g:Z

    iput-object p1, p0, Lk/b;->a:Lj0/k;

    iput-object p2, p0, Lk/b;->c:Lcom/amap/api/maps/TextureMapView;

    invoke-virtual {p2}, Lcom/amap/api/maps/TextureMapView;->getMap()Lcom/amap/api/maps/AMap;

    move-result-object p1

    iput-object p1, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    invoke-virtual {p1, p0}, Lcom/amap/api/maps/AMap;->addOnMapLoadedListener(Lcom/amap/api/maps/AMap$OnMapLoadedListener;)V

    invoke-virtual {p1, p0}, Lcom/amap/api/maps/AMap;->addOnMyLocationChangeListener(Lcom/amap/api/maps/AMap$OnMyLocationChangeListener;)V

    invoke-virtual {p1, p0}, Lcom/amap/api/maps/AMap;->addOnCameraChangeListener(Lcom/amap/api/maps/AMap$OnCameraChangeListener;)V

    invoke-virtual {p1, p0}, Lcom/amap/api/maps/AMap;->addOnMapLongClickListener(Lcom/amap/api/maps/AMap$OnMapLongClickListener;)V

    invoke-virtual {p1, p0}, Lcom/amap/api/maps/AMap;->addOnMapClickListener(Lcom/amap/api/maps/AMap$OnMapClickListener;)V

    invoke-virtual {p1, p0}, Lcom/amap/api/maps/AMap;->addOnPOIClickListener(Lcom/amap/api/maps/AMap$OnPOIClickListener;)V

    return-void
.end method

.method private s()Lcom/amap/api/maps/model/CameraPosition;
    .locals 1

    iget-object v0, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Lcom/amap/api/maps/AMap;->getCameraPosition()Lcom/amap/api/maps/model/CameraPosition;

    move-result-object v0

    return-object v0

    :cond_0
    const/4 v0, 0x0

    return-object v0
.end method

.method private u(Lcom/amap/api/maps/CameraUpdate;Ljava/lang/Object;Ljava/lang/Object;)V
    .locals 2

    if-eqz p2, :cond_0

    check-cast p2, Ljava/lang/Boolean;

    invoke-virtual {p2}, Ljava/lang/Boolean;->booleanValue()Z

    move-result p2

    goto :goto_0

    :cond_0
    const/4 p2, 0x0

    :goto_0
    if-eqz p3, :cond_1

    check-cast p3, Ljava/lang/Number;

    invoke-virtual {p3}, Ljava/lang/Number;->intValue()I

    move-result p3

    int-to-long v0, p3

    goto :goto_1

    :cond_1
    const-wide/16 v0, 0xfa

    :goto_1
    iget-object p3, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    if-eqz p3, :cond_3

    if-eqz p2, :cond_2

    const/4 p2, 0x0

    invoke-virtual {p3, p1, v0, v1, p2}, Lcom/amap/api/maps/AMap;->animateCamera(Lcom/amap/api/maps/CameraUpdate;JLcom/amap/api/maps/AMap$CancelableCallback;)V

    goto :goto_2

    :cond_2
    invoke-virtual {p3, p1}, Lcom/amap/api/maps/AMap;->moveCamera(Lcom/amap/api/maps/CameraUpdate;)V

    :cond_3
    :goto_2
    return-void
.end method


# virtual methods
.method public a(I)V
    .locals 1

    iget-object v0, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/AMap;->setMapType(I)V

    return-void
.end method

.method public b(Z)V
    .locals 1

    iget-object v0, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/AMap;->showBuildings(Z)V

    return-void
.end method

.method public c(Z)V
    .locals 1

    iget-object v0, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    invoke-virtual {v0}, Lcom/amap/api/maps/AMap;->getUiSettings()Lcom/amap/api/maps/UiSettings;

    move-result-object v0

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/UiSettings;->setScaleControlsEnabled(Z)V

    return-void
.end method

.method public d(Z)V
    .locals 1

    iget-object v0, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    invoke-virtual {v0}, Lcom/amap/api/maps/AMap;->getUiSettings()Lcom/amap/api/maps/UiSettings;

    move-result-object v0

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/UiSettings;->setCompassEnabled(Z)V

    return-void
.end method

.method public e(Z)V
    .locals 1

    iget-object v0, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/AMap;->setTouchPoiEnable(Z)V

    return-void
.end method

.method public f(Lj0/j;Lj0/k$d;)V
    .locals 4

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "doMethodCall===>"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p1, Lj0/j;->a:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v1, "MapController"

    invoke-static {v1, v0}, Lp/c;->b(Ljava/lang/String;Ljava/lang/String;)V

    iget-object v0, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    if-nez v0, :cond_0

    const-string p1, "onMethodCall amap is null!!!"

    invoke-static {v1, p1}, Lp/c;->c(Ljava/lang/String;Ljava/lang/String;)V

    return-void

    :cond_0
    iget-object v0, p1, Lj0/j;->a:Ljava/lang/String;

    invoke-virtual {v0}, Ljava/lang/String;->hashCode()I

    const/4 v2, -0x1

    invoke-virtual {v0}, Ljava/lang/String;->hashCode()I

    move-result v3

    sparse-switch v3, :sswitch_data_0

    goto/16 :goto_0

    :sswitch_0
    const-string v3, "camera#move"

    invoke-virtual {v0, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_1

    goto :goto_0

    :cond_1
    const/4 v2, 0x7

    goto :goto_0

    :sswitch_1
    const-string v3, "map#setRenderFps"

    invoke-virtual {v0, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_2

    goto :goto_0

    :cond_2
    const/4 v2, 0x6

    goto :goto_0

    :sswitch_2
    const-string v3, "map#takeSnapshot"

    invoke-virtual {v0, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_3

    goto :goto_0

    :cond_3
    const/4 v2, 0x5

    goto :goto_0

    :sswitch_3
    const-string v3, "map#waitForMap"

    invoke-virtual {v0, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_4

    goto :goto_0

    :cond_4
    const/4 v2, 0x4

    goto :goto_0

    :sswitch_4
    const-string v3, "map#clearDisk"

    invoke-virtual {v0, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_5

    goto :goto_0

    :cond_5
    const/4 v2, 0x3

    goto :goto_0

    :sswitch_5
    const-string v3, "map#contentApprovalNumber"

    invoke-virtual {v0, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_6

    goto :goto_0

    :cond_6
    const/4 v2, 0x2

    goto :goto_0

    :sswitch_6
    const-string v3, "map#update"

    invoke-virtual {v0, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_7

    goto :goto_0

    :cond_7
    const/4 v2, 0x1

    goto :goto_0

    :sswitch_7
    const-string v3, "map#satelliteImageApprovalNumber"

    invoke-virtual {v0, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_8

    goto :goto_0

    :cond_8
    const/4 v2, 0x0

    :goto_0
    const/4 v0, 0x0

    packed-switch v2, :pswitch_data_0

    new-instance p2, Ljava/lang/StringBuilder;

    invoke-direct {p2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v0, "onMethodCall not find methodId:"

    invoke-virtual {p2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object p1, p1, Lj0/j;->a:Ljava/lang/String;

    invoke-virtual {p2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {v1, p1}, Lp/c;->c(Ljava/lang/String;Ljava/lang/String;)V

    goto/16 :goto_3

    :pswitch_0
    iget-object p2, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    if-eqz p2, :cond_a

    const-string p2, "cameraUpdate"

    invoke-virtual {p1, p2}, Lj0/j;->a(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p2

    invoke-static {p2}, Lp/b;->m(Ljava/lang/Object;)Lcom/amap/api/maps/CameraUpdate;

    move-result-object p2

    const-string v0, "animated"

    invoke-virtual {p1, v0}, Lj0/j;->a(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    const-string v1, "duration"

    invoke-virtual {p1, v1}, Lj0/j;->a(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    invoke-direct {p0, p2, v0, p1}, Lk/b;->u(Lcom/amap/api/maps/CameraUpdate;Ljava/lang/Object;Ljava/lang/Object;)V

    goto :goto_3

    :pswitch_1
    iget-object v1, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    if-eqz v1, :cond_a

    const-string v2, "fps"

    invoke-virtual {p1, v2}, Lj0/j;->a(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/Integer;

    invoke-virtual {p1}, Ljava/lang/Integer;->intValue()I

    move-result p1

    invoke-virtual {v1, p1}, Lcom/amap/api/maps/AMap;->setRenderFps(I)V

    :goto_1
    invoke-interface {p2, v0}, Lj0/k$d;->a(Ljava/lang/Object;)V

    goto :goto_3

    :pswitch_2
    iget-object p1, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    if-eqz p1, :cond_a

    new-instance v0, Lk/b$a;

    invoke-direct {v0, p0, p2}, Lk/b$a;-><init>(Lk/b;Lj0/k$d;)V

    invoke-virtual {p1, v0}, Lcom/amap/api/maps/AMap;->getMapScreenShot(Lcom/amap/api/maps/AMap$OnMapScreenShotListener;)V

    goto :goto_3

    :pswitch_3
    iget-boolean p1, p0, Lk/b;->f:Z

    if-eqz p1, :cond_9

    invoke-interface {p2, v0}, Lj0/k$d;->a(Ljava/lang/Object;)V

    return-void

    :cond_9
    iput-object p2, p0, Lk/b;->d:Lj0/k$d;

    goto :goto_3

    :pswitch_4
    iget-object p1, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    if-eqz p1, :cond_a

    invoke-virtual {p1}, Lcom/amap/api/maps/AMap;->removecache()V

    goto :goto_1

    :pswitch_5
    iget-object p1, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    if-eqz p1, :cond_a

    invoke-virtual {p1}, Lcom/amap/api/maps/AMap;->getMapContentApprovalNumber()Ljava/lang/String;

    move-result-object p1

    goto :goto_2

    :pswitch_6
    iget-object v0, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    if-eqz v0, :cond_a

    const-string v0, "options"

    invoke-virtual {p1, v0}, Lj0/j;->a(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    invoke-static {p1, p0}, Lp/b;->e(Ljava/lang/Object;Lk/a;)V

    invoke-direct {p0}, Lk/b;->s()Lcom/amap/api/maps/model/CameraPosition;

    move-result-object p1

    invoke-static {p1}, Lp/b;->a(Lcom/amap/api/maps/model/CameraPosition;)Ljava/lang/Object;

    move-result-object p1

    goto :goto_2

    :pswitch_7
    iget-object p1, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    if-eqz p1, :cond_a

    invoke-virtual {p1}, Lcom/amap/api/maps/AMap;->getSatelliteImageApprovalNumber()Ljava/lang/String;

    move-result-object p1

    :goto_2
    invoke-interface {p2, p1}, Lj0/k$d;->a(Ljava/lang/Object;)V

    :cond_a
    :goto_3
    return-void

    :sswitch_data_0
    .sparse-switch
        -0x67f429cd -> :sswitch_7
        -0x52ced230 -> :sswitch_6
        -0x4f541ba2 -> :sswitch_5
        -0x49959cdd -> :sswitch_4
        0x11956b2f -> :sswitch_3
        0x19decb32 -> :sswitch_2
        0x4d9868f8 -> :sswitch_1
        0x776bde6f -> :sswitch_0
    .end sparse-switch

    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_7
        :pswitch_6
        :pswitch_5
        :pswitch_4
        :pswitch_3
        :pswitch_2
        :pswitch_1
        :pswitch_0
    .end packed-switch
.end method

.method public g(Z)V
    .locals 1

    iget-object v0, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    invoke-virtual {v0}, Lcom/amap/api/maps/AMap;->getUiSettings()Lcom/amap/api/maps/UiSettings;

    move-result-object v0

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/UiSettings;->setScrollGesturesEnabled(Z)V

    return-void
.end method

.method public h(F)V
    .locals 1

    iget-object v0, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/AMap;->setMaxZoomLevel(F)V

    return-void
.end method

.method public i(Lcom/amap/api/maps/model/MyLocationStyle;)V
    .locals 2

    iget-object v0, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    if-eqz v0, :cond_0

    invoke-virtual {p1}, Lcom/amap/api/maps/model/MyLocationStyle;->isMyLocationShowing()Z

    move-result v0

    iput-boolean v0, p0, Lk/b;->g:Z

    iget-object v1, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    invoke-virtual {v1, v0}, Lcom/amap/api/maps/AMap;->setMyLocationEnabled(Z)V

    iget-object v0, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/AMap;->setMyLocationStyle(Lcom/amap/api/maps/model/MyLocationStyle;)V

    :cond_0
    return-void
.end method

.method public j(Lcom/amap/api/maps/model/CustomMapStyleOptions;)V
    .locals 1

    iget-object v0, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    if-eqz v0, :cond_0

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/AMap;->setCustomMapStyle(Lcom/amap/api/maps/model/CustomMapStyleOptions;)V

    :cond_0
    return-void
.end method

.method public k(Z)V
    .locals 1

    iget-object v0, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/AMap;->showMapText(Z)V

    return-void
.end method

.method public l(Z)V
    .locals 1

    iget-object v0, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    invoke-virtual {v0}, Lcom/amap/api/maps/AMap;->getUiSettings()Lcom/amap/api/maps/UiSettings;

    move-result-object v0

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/UiSettings;->setTiltGesturesEnabled(Z)V

    return-void
.end method

.method public m(FF)V
    .locals 2

    iget-object v0, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    iget-object v1, p0, Lk/b;->c:Lcom/amap/api/maps/TextureMapView;

    invoke-virtual {v1}, Lcom/amap/api/maps/TextureMapView;->getWidth()I

    move-result v1

    int-to-float v1, v1

    mul-float v1, v1, p1

    invoke-static {v1}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object p1

    invoke-virtual {p1}, Ljava/lang/Float;->intValue()I

    move-result p1

    iget-object v1, p0, Lk/b;->c:Lcom/amap/api/maps/TextureMapView;

    invoke-virtual {v1}, Lcom/amap/api/maps/TextureMapView;->getHeight()I

    move-result v1

    int-to-float v1, v1

    mul-float v1, v1, p2

    invoke-static {v1}, Ljava/lang/Float;->valueOf(F)Ljava/lang/Float;

    move-result-object p2

    invoke-virtual {p2}, Ljava/lang/Float;->intValue()I

    move-result p2

    invoke-virtual {v0, p1, p2}, Lcom/amap/api/maps/AMap;->setPointToCenter(II)V

    return-void
.end method

.method public n(Z)V
    .locals 1

    iget-object v0, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    invoke-virtual {v0}, Lcom/amap/api/maps/AMap;->getUiSettings()Lcom/amap/api/maps/UiSettings;

    move-result-object v0

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/UiSettings;->setZoomGesturesEnabled(Z)V

    return-void
.end method

.method public o(F)V
    .locals 1

    iget-object v0, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/AMap;->setMinZoomLevel(F)V

    return-void
.end method

.method public p(Z)V
    .locals 1

    iget-object v0, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/AMap;->setTrafficEnabled(Z)V

    return-void
.end method

.method public q(Lcom/amap/api/maps/model/LatLngBounds;)V
    .locals 1

    iget-object v0, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/AMap;->setMapStatusLimits(Lcom/amap/api/maps/model/LatLngBounds;)V

    return-void
.end method

.method public r(Z)V
    .locals 1

    iget-object v0, p0, Lk/b;->b:Lcom/amap/api/maps/AMap;

    invoke-virtual {v0}, Lcom/amap/api/maps/AMap;->getUiSettings()Lcom/amap/api/maps/UiSettings;

    move-result-object v0

    invoke-virtual {v0, p1}, Lcom/amap/api/maps/UiSettings;->setRotateGesturesEnabled(Z)V

    return-void
.end method

.method public t()[Ljava/lang/String;
    .locals 1

    sget-object v0, Lp/a;->a:[Ljava/lang/String;

    return-object v0
.end method
