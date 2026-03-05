.class public Li/b;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lcom/amap/api/location/AMapLocationListener;


# instance fields
.field private a:Landroid/content/Context;

.field private b:Lcom/amap/api/location/AMapLocationClientOption;

.field private c:Lcom/amap/api/location/AMapLocationClient;

.field private d:Lj0/d$b;

.field private e:Ljava/lang/String;


# direct methods
.method public constructor <init>(Landroid/content/Context;Ljava/lang/String;Lj0/d$b;)V
    .locals 1

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    new-instance v0, Lcom/amap/api/location/AMapLocationClientOption;

    invoke-direct {v0}, Lcom/amap/api/location/AMapLocationClientOption;-><init>()V

    iput-object v0, p0, Li/b;->b:Lcom/amap/api/location/AMapLocationClientOption;

    const/4 v0, 0x0

    iput-object v0, p0, Li/b;->c:Lcom/amap/api/location/AMapLocationClient;

    iput-object p1, p0, Li/b;->a:Landroid/content/Context;

    iput-object p2, p0, Li/b;->e:Ljava/lang/String;

    iput-object p3, p0, Li/b;->d:Lj0/d$b;

    :try_start_0
    new-instance p2, Lcom/amap/api/location/AMapLocationClient;

    invoke-direct {p2, p1}, Lcom/amap/api/location/AMapLocationClient;-><init>(Landroid/content/Context;)V

    iput-object p2, p0, Li/b;->c:Lcom/amap/api/location/AMapLocationClient;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception p1

    invoke-virtual {p1}, Ljava/lang/Throwable;->printStackTrace()V

    :goto_0
    return-void
.end method


# virtual methods
.method public a()V
    .locals 1

    iget-object v0, p0, Li/b;->c:Lcom/amap/api/location/AMapLocationClient;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Lcom/amap/api/location/AMapLocationClient;->onDestroy()V

    const/4 v0, 0x0

    iput-object v0, p0, Li/b;->c:Lcom/amap/api/location/AMapLocationClient;

    :cond_0
    return-void
.end method

.method public b(Ljava/util/Map;)V
    .locals 4

    iget-object v0, p0, Li/b;->b:Lcom/amap/api/location/AMapLocationClientOption;

    if-nez v0, :cond_0

    new-instance v0, Lcom/amap/api/location/AMapLocationClientOption;

    invoke-direct {v0}, Lcom/amap/api/location/AMapLocationClientOption;-><init>()V

    iput-object v0, p0, Li/b;->b:Lcom/amap/api/location/AMapLocationClientOption;

    :cond_0
    const-string v0, "locationInterval"

    invoke-interface {p1, v0}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_1

    iget-object v1, p0, Li/b;->b:Lcom/amap/api/location/AMapLocationClientOption;

    invoke-interface {p1, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->longValue()J

    move-result-wide v2

    invoke-virtual {v1, v2, v3}, Lcom/amap/api/location/AMapLocationClientOption;->setInterval(J)Lcom/amap/api/location/AMapLocationClientOption;

    :cond_1
    const-string v0, "needAddress"

    invoke-interface {p1, v0}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_2

    iget-object v1, p0, Li/b;->b:Lcom/amap/api/location/AMapLocationClientOption;

    invoke-interface {p1, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Boolean;

    invoke-virtual {v0}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v0

    invoke-virtual {v1, v0}, Lcom/amap/api/location/AMapLocationClientOption;->setNeedAddress(Z)Lcom/amap/api/location/AMapLocationClientOption;

    :cond_2
    const-string v0, "locationMode"

    invoke-interface {p1, v0}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_3

    :try_start_0
    iget-object v1, p0, Li/b;->b:Lcom/amap/api/location/AMapLocationClientOption;

    invoke-static {}, Lcom/amap/api/location/AMapLocationClientOption$AMapLocationMode;->values()[Lcom/amap/api/location/AMapLocationClientOption$AMapLocationMode;

    move-result-object v2

    invoke-interface {p1, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    aget-object v0, v2, v0

    invoke-virtual {v1, v0}, Lcom/amap/api/location/AMapLocationClientOption;->setLocationMode(Lcom/amap/api/location/AMapLocationClientOption$AMapLocationMode;)Lcom/amap/api/location/AMapLocationClientOption;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    nop

    :cond_3
    :goto_0
    const-string v0, "geoLanguage"

    invoke-interface {p1, v0}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_4

    iget-object v1, p0, Li/b;->b:Lcom/amap/api/location/AMapLocationClientOption;

    invoke-static {}, Lcom/amap/api/location/AMapLocationClientOption$GeoLanguage;->values()[Lcom/amap/api/location/AMapLocationClientOption$GeoLanguage;

    move-result-object v2

    invoke-interface {p1, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    aget-object v0, v2, v0

    invoke-virtual {v1, v0}, Lcom/amap/api/location/AMapLocationClientOption;->setGeoLanguage(Lcom/amap/api/location/AMapLocationClientOption$GeoLanguage;)Lcom/amap/api/location/AMapLocationClientOption;

    :cond_4
    const-string v0, "onceLocation"

    invoke-interface {p1, v0}, Ljava/util/Map;->containsKey(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_5

    iget-object v1, p0, Li/b;->b:Lcom/amap/api/location/AMapLocationClientOption;

    invoke-interface {p1, v0}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/Boolean;

    invoke-virtual {p1}, Ljava/lang/Boolean;->booleanValue()Z

    move-result p1

    invoke-virtual {v1, p1}, Lcom/amap/api/location/AMapLocationClientOption;->setOnceLocation(Z)Lcom/amap/api/location/AMapLocationClientOption;

    :cond_5
    iget-object p1, p0, Li/b;->c:Lcom/amap/api/location/AMapLocationClient;

    if-eqz p1, :cond_6

    iget-object v0, p0, Li/b;->b:Lcom/amap/api/location/AMapLocationClientOption;

    invoke-virtual {p1, v0}, Lcom/amap/api/location/AMapLocationClient;->setLocationOption(Lcom/amap/api/location/AMapLocationClientOption;)V

    :cond_6
    return-void
.end method

.method public c()V
    .locals 2

    :try_start_0
    iget-object v0, p0, Li/b;->c:Lcom/amap/api/location/AMapLocationClient;

    if-nez v0, :cond_0

    new-instance v0, Lcom/amap/api/location/AMapLocationClient;

    iget-object v1, p0, Li/b;->a:Landroid/content/Context;

    invoke-direct {v0, v1}, Lcom/amap/api/location/AMapLocationClient;-><init>(Landroid/content/Context;)V

    iput-object v0, p0, Li/b;->c:Lcom/amap/api/location/AMapLocationClient;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v0

    invoke-virtual {v0}, Ljava/lang/Throwable;->printStackTrace()V

    :cond_0
    :goto_0
    iget-object v0, p0, Li/b;->b:Lcom/amap/api/location/AMapLocationClientOption;

    if-eqz v0, :cond_1

    iget-object v1, p0, Li/b;->c:Lcom/amap/api/location/AMapLocationClient;

    invoke-virtual {v1, v0}, Lcom/amap/api/location/AMapLocationClient;->setLocationOption(Lcom/amap/api/location/AMapLocationClientOption;)V

    iget-object v0, p0, Li/b;->c:Lcom/amap/api/location/AMapLocationClient;

    invoke-virtual {v0, p0}, Lcom/amap/api/location/AMapLocationClient;->setLocationListener(Lcom/amap/api/location/AMapLocationListener;)V

    iget-object v0, p0, Li/b;->c:Lcom/amap/api/location/AMapLocationClient;

    invoke-virtual {v0}, Lcom/amap/api/location/AMapLocationClient;->startLocation()V

    :cond_1
    return-void
.end method

.method public d()V
    .locals 1

    iget-object v0, p0, Li/b;->c:Lcom/amap/api/location/AMapLocationClient;

    if-eqz v0, :cond_0

    invoke-virtual {v0}, Lcom/amap/api/location/AMapLocationClient;->stopLocation()V

    iget-object v0, p0, Li/b;->c:Lcom/amap/api/location/AMapLocationClient;

    invoke-virtual {v0}, Lcom/amap/api/location/AMapLocationClient;->onDestroy()V

    const/4 v0, 0x0

    iput-object v0, p0, Li/b;->c:Lcom/amap/api/location/AMapLocationClient;

    :cond_0
    return-void
.end method
