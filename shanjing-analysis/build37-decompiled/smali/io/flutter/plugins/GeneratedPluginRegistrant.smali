.class public final Lio/flutter/plugins/GeneratedPluginRegistrant;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation build Landroidx/annotation/Keep;
.end annotation


# static fields
.field private static final TAG:Ljava/lang/String; = "GeneratedPluginRegistrant"


# direct methods
.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static registerWith(Lio/flutter/embedding/engine/a;)V
    .locals 3

    const-string v0, "GeneratedPluginRegistrant"

    :try_start_0
    invoke-virtual {p0}, Lio/flutter/embedding/engine/a;->q()Lb0/b;

    move-result-object v1

    new-instance v2, Li/a;

    invoke-direct {v2}, Li/a;-><init>()V

    invoke-interface {v1, v2}, Lb0/b;->g(Lb0/a;)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    goto :goto_0

    :catch_0
    move-exception v1

    const-string v2, "Error registering plugin amap_flutter_location, com.amap.flutter.location.AMapFlutterLocationPlugin"

    invoke-static {v0, v2, v1}, Lw/b;->c(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    :goto_0
    :try_start_1
    invoke-virtual {p0}, Lio/flutter/embedding/engine/a;->q()Lb0/b;

    move-result-object v1

    new-instance v2, Lcom/amap/flutter/map/a;

    invoke-direct {v2}, Lcom/amap/flutter/map/a;-><init>()V

    invoke-interface {v1, v2}, Lb0/b;->g(Lb0/a;)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1

    goto :goto_1

    :catch_1
    move-exception v1

    const-string v2, "Error registering plugin amap_flutter_map, com.amap.flutter.map.AMapFlutterMapPlugin"

    invoke-static {v0, v2, v1}, Lw/b;->c(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    :goto_1
    :try_start_2
    invoke-virtual {p0}, Lio/flutter/embedding/engine/a;->q()Lb0/b;

    move-result-object v1

    new-instance v2, Lv/h;

    invoke-direct {v2}, Lv/h;-><init>()V

    invoke-interface {v1, v2}, Lb0/b;->g(Lb0/a;)V
    :try_end_2
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_2

    goto :goto_2

    :catch_2
    move-exception v1

    const-string v2, "Error registering plugin connectivity_plus, dev.fluttercommunity.plus.connectivity.ConnectivityPlugin"

    invoke-static {v0, v2, v1}, Lw/b;->c(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    :goto_2
    :try_start_3
    invoke-virtual {p0}, Lio/flutter/embedding/engine/a;->q()Lb0/b;

    move-result-object v1

    new-instance v2, Ln0/a;

    invoke-direct {v2}, Ln0/a;-><init>()V

    invoke-interface {v1, v2}, Lb0/b;->g(Lb0/a;)V
    :try_end_3
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_3} :catch_3

    goto :goto_3

    :catch_3
    move-exception v1

    const-string v2, "Error registering plugin flutter_plugin_android_lifecycle, io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin"

    invoke-static {v0, v2, v1}, Lw/b;->c(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    :goto_3
    :try_start_4
    invoke-virtual {p0}, Lio/flutter/embedding/engine/a;->q()Lb0/b;

    move-result-object v1

    new-instance v2, Lu/i;

    invoke-direct {v2}, Lu/i;-><init>()V

    invoke-interface {v1, v2}, Lb0/b;->g(Lb0/a;)V
    :try_end_4
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_4} :catch_4

    goto :goto_4

    :catch_4
    move-exception v1

    const-string v2, "Error registering plugin flutter_tts, com.tundralabs.fluttertts.FlutterTtsPlugin"

    invoke-static {v0, v2, v1}, Lw/b;->c(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    :goto_4
    :try_start_5
    invoke-virtual {p0}, Lio/flutter/embedding/engine/a;->q()Lb0/b;

    move-result-object v1

    new-instance v2, Lo0/j;

    invoke-direct {v2}, Lo0/j;-><init>()V

    invoke-interface {v1, v2}, Lb0/b;->g(Lb0/a;)V
    :try_end_5
    .catch Ljava/lang/Exception; {:try_start_5 .. :try_end_5} :catch_5

    goto :goto_5

    :catch_5
    move-exception v1

    const-string v2, "Error registering plugin path_provider_android, io.flutter.plugins.pathprovider.PathProviderPlugin"

    invoke-static {v0, v2, v1}, Lw/b;->c(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    :goto_5
    :try_start_6
    invoke-virtual {p0}, Lio/flutter/embedding/engine/a;->q()Lb0/b;

    move-result-object v1

    new-instance v2, Lq/m;

    invoke-direct {v2}, Lq/m;-><init>()V

    invoke-interface {v1, v2}, Lb0/b;->g(Lb0/a;)V
    :try_end_6
    .catch Ljava/lang/Exception; {:try_start_6 .. :try_end_6} :catch_6

    goto :goto_6

    :catch_6
    move-exception v1

    const-string v2, "Error registering plugin permission_handler_android, com.baseflow.permissionhandler.PermissionHandlerPlugin"

    invoke-static {v0, v2, v1}, Lw/b;->c(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    :goto_6
    :try_start_7
    invoke-virtual {p0}, Lio/flutter/embedding/engine/a;->q()Lb0/b;

    move-result-object p0

    new-instance v1, Lr/c0;

    invoke-direct {v1}, Lr/c0;-><init>()V

    invoke-interface {p0, v1}, Lb0/b;->g(Lb0/a;)V
    :try_end_7
    .catch Ljava/lang/Exception; {:try_start_7 .. :try_end_7} :catch_7

    goto :goto_7

    :catch_7
    move-exception p0

    const-string v1, "Error registering plugin sqflite, com.tekartik.sqflite.SqflitePlugin"

    invoke-static {v0, v1, p0}, Lw/b;->c(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)V

    :goto_7
    return-void
.end method
