.class public Lp/a;
.super Ljava/lang/Object;
.source "SourceFile"


# static fields
.field public static final a:[Ljava/lang/String;

.field public static final b:[Ljava/lang/String;

.field public static final c:[Ljava/lang/String;

.field public static final d:[Ljava/lang/String;


# direct methods
.method static constructor <clinit>()V
    .locals 8

    const-string v0, "map#contentApprovalNumber"

    const-string v1, "map#satelliteImageApprovalNumber"

    const-string v2, "map#waitForMap"

    const-string v3, "map#update"

    const-string v4, "camera#move"

    const-string v5, "map#setRenderFps"

    const-string v6, "map#takeSnapshot"

    const-string v7, "map#clearDisk"

    filled-new-array/range {v0 .. v7}, [Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lp/a;->a:[Ljava/lang/String;

    const-string v0, "markers#update"

    filled-new-array {v0}, [Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lp/a;->b:[Ljava/lang/String;

    const-string v0, "polygons#update"

    filled-new-array {v0}, [Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lp/a;->c:[Ljava/lang/String;

    const-string v0, "polylines#update"

    filled-new-array {v0}, [Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lp/a;->d:[Ljava/lang/String;

    return-void
.end method
