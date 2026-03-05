.class public Lcom/amap/flutter/map/a;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lb0/a;
.implements Lc0/a;


# instance fields
.field private a:Lb0/a$b;

.field private b:Landroidx/lifecycle/d;


# direct methods
.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method static synthetic b(Lcom/amap/flutter/map/a;)Landroidx/lifecycle/d;
    .locals 0

    iget-object p0, p0, Lcom/amap/flutter/map/a;->b:Landroidx/lifecycle/d;

    return-object p0
.end method


# virtual methods
.method public a(Lb0/a$b;)V
    .locals 1

    const-string p1, "AMapFlutterMapPlugin"

    const-string v0, "onDetachedFromEngine==>"

    invoke-static {p1, v0}, Lp/c;->b(Ljava/lang/String;Ljava/lang/String;)V

    const/4 p1, 0x0

    iput-object p1, p0, Lcom/amap/flutter/map/a;->a:Lb0/a$b;

    return-void
.end method

.method public c()V
    .locals 2

    const-string v0, "AMapFlutterMapPlugin"

    const-string v1, "onDetachedFromActivity==>"

    invoke-static {v0, v1}, Lp/c;->b(Ljava/lang/String;Ljava/lang/String;)V

    const/4 v0, 0x0

    iput-object v0, p0, Lcom/amap/flutter/map/a;->b:Landroidx/lifecycle/d;

    return-void
.end method

.method public d(Lc0/c;)V
    .locals 2

    const-string v0, "AMapFlutterMapPlugin"

    const-string v1, "onAttachedToActivity==>"

    invoke-static {v0, v1}, Lp/c;->b(Ljava/lang/String;Ljava/lang/String;)V

    invoke-static {p1}, Lf0/a;->a(Lc0/c;)Landroidx/lifecycle/d;

    move-result-object p1

    iput-object p1, p0, Lcom/amap/flutter/map/a;->b:Landroidx/lifecycle/d;

    return-void
.end method

.method public g()V
    .locals 2

    const-string v0, "AMapFlutterMapPlugin"

    const-string v1, "onDetachedFromActivityForConfigChanges==>"

    invoke-static {v0, v1}, Lp/c;->b(Ljava/lang/String;Ljava/lang/String;)V

    invoke-virtual {p0}, Lcom/amap/flutter/map/a;->c()V

    return-void
.end method

.method public h(Lc0/c;)V
    .locals 2

    const-string v0, "AMapFlutterMapPlugin"

    const-string v1, "onReattachedToActivityForConfigChanges==>"

    invoke-static {v0, v1}, Lp/c;->b(Ljava/lang/String;Ljava/lang/String;)V

    invoke-virtual {p0, p1}, Lcom/amap/flutter/map/a;->d(Lc0/c;)V

    return-void
.end method

.method public i(Lb0/a$b;)V
    .locals 3

    const-string v0, "AMapFlutterMapPlugin"

    const-string v1, "onAttachedToEngine==>"

    invoke-static {v0, v1}, Lp/c;->b(Ljava/lang/String;Ljava/lang/String;)V

    iput-object p1, p0, Lcom/amap/flutter/map/a;->a:Lb0/a$b;

    invoke-virtual {p1}, Lb0/a$b;->c()Lio/flutter/plugin/platform/m;

    move-result-object v0

    new-instance v1, Lcom/amap/flutter/map/c;

    invoke-virtual {p1}, Lb0/a$b;->b()Lj0/c;

    move-result-object p1

    new-instance v2, Lcom/amap/flutter/map/a$a;

    invoke-direct {v2, p0}, Lcom/amap/flutter/map/a$a;-><init>(Lcom/amap/flutter/map/a;)V

    invoke-direct {v1, p1, v2}, Lcom/amap/flutter/map/c;-><init>(Lj0/c;Lj/a;)V

    const-string p1, "com.amap.flutter.map"

    invoke-interface {v0, p1, v1}, Lio/flutter/plugin/platform/m;->a(Ljava/lang/String;Lio/flutter/plugin/platform/l;)Z

    return-void
.end method
