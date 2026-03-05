.class public final enum Lio/flutter/embedding/android/v$a;
.super Ljava/lang/Enum;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/embedding/android/v;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x4019
    name = "a"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Enum<",
        "Lio/flutter/embedding/android/v$a;",
        ">;"
    }
.end annotation


# static fields
.field public static final enum e:Lio/flutter/embedding/android/v$a;

.field public static final enum f:Lio/flutter/embedding/android/v$a;

.field public static final enum g:Lio/flutter/embedding/android/v$a;

.field public static final enum h:Lio/flutter/embedding/android/v$a;

.field public static final enum i:Lio/flutter/embedding/android/v$a;

.field private static final synthetic j:[Lio/flutter/embedding/android/v$a;


# instance fields
.field private final d:J


# direct methods
.method static constructor <clinit>()V
    .locals 5

    new-instance v0, Lio/flutter/embedding/android/v$a;

    const-string v1, "kKeyboard"

    const/4 v2, 0x0

    const-wide/16 v3, 0x0

    invoke-direct {v0, v1, v2, v3, v4}, Lio/flutter/embedding/android/v$a;-><init>(Ljava/lang/String;IJ)V

    sput-object v0, Lio/flutter/embedding/android/v$a;->e:Lio/flutter/embedding/android/v$a;

    new-instance v0, Lio/flutter/embedding/android/v$a;

    const-string v1, "kDirectionalPad"

    const/4 v2, 0x1

    const-wide/16 v3, 0x1

    invoke-direct {v0, v1, v2, v3, v4}, Lio/flutter/embedding/android/v$a;-><init>(Ljava/lang/String;IJ)V

    sput-object v0, Lio/flutter/embedding/android/v$a;->f:Lio/flutter/embedding/android/v$a;

    new-instance v0, Lio/flutter/embedding/android/v$a;

    const-string v1, "kGamepad"

    const/4 v2, 0x2

    const-wide/16 v3, 0x2

    invoke-direct {v0, v1, v2, v3, v4}, Lio/flutter/embedding/android/v$a;-><init>(Ljava/lang/String;IJ)V

    sput-object v0, Lio/flutter/embedding/android/v$a;->g:Lio/flutter/embedding/android/v$a;

    new-instance v0, Lio/flutter/embedding/android/v$a;

    const-string v1, "kJoystick"

    const/4 v2, 0x3

    const-wide/16 v3, 0x3

    invoke-direct {v0, v1, v2, v3, v4}, Lio/flutter/embedding/android/v$a;-><init>(Ljava/lang/String;IJ)V

    sput-object v0, Lio/flutter/embedding/android/v$a;->h:Lio/flutter/embedding/android/v$a;

    new-instance v0, Lio/flutter/embedding/android/v$a;

    const-string v1, "kHdmi"

    const/4 v2, 0x4

    const-wide/16 v3, 0x4

    invoke-direct {v0, v1, v2, v3, v4}, Lio/flutter/embedding/android/v$a;-><init>(Ljava/lang/String;IJ)V

    sput-object v0, Lio/flutter/embedding/android/v$a;->i:Lio/flutter/embedding/android/v$a;

    invoke-static {}, Lio/flutter/embedding/android/v$a;->a()[Lio/flutter/embedding/android/v$a;

    move-result-object v0

    sput-object v0, Lio/flutter/embedding/android/v$a;->j:[Lio/flutter/embedding/android/v$a;

    return-void
.end method

.method private constructor <init>(Ljava/lang/String;IJ)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(J)V"
        }
    .end annotation

    invoke-direct {p0, p1, p2}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    iput-wide p3, p0, Lio/flutter/embedding/android/v$a;->d:J

    return-void
.end method

.method private static synthetic a()[Lio/flutter/embedding/android/v$a;
    .locals 3

    const/4 v0, 0x5

    new-array v0, v0, [Lio/flutter/embedding/android/v$a;

    sget-object v1, Lio/flutter/embedding/android/v$a;->e:Lio/flutter/embedding/android/v$a;

    const/4 v2, 0x0

    aput-object v1, v0, v2

    sget-object v1, Lio/flutter/embedding/android/v$a;->f:Lio/flutter/embedding/android/v$a;

    const/4 v2, 0x1

    aput-object v1, v0, v2

    sget-object v1, Lio/flutter/embedding/android/v$a;->g:Lio/flutter/embedding/android/v$a;

    const/4 v2, 0x2

    aput-object v1, v0, v2

    sget-object v1, Lio/flutter/embedding/android/v$a;->h:Lio/flutter/embedding/android/v$a;

    const/4 v2, 0x3

    aput-object v1, v0, v2

    sget-object v1, Lio/flutter/embedding/android/v$a;->i:Lio/flutter/embedding/android/v$a;

    const/4 v2, 0x4

    aput-object v1, v0, v2

    return-object v0
.end method

.method public static valueOf(Ljava/lang/String;)Lio/flutter/embedding/android/v$a;
    .locals 1

    const-class v0, Lio/flutter/embedding/android/v$a;

    invoke-static {v0, p0}, Ljava/lang/Enum;->valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;

    move-result-object p0

    check-cast p0, Lio/flutter/embedding/android/v$a;

    return-object p0
.end method

.method public static values()[Lio/flutter/embedding/android/v$a;
    .locals 1

    sget-object v0, Lio/flutter/embedding/android/v$a;->j:[Lio/flutter/embedding/android/v$a;

    invoke-virtual {v0}, [Lio/flutter/embedding/android/v$a;->clone()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Lio/flutter/embedding/android/v$a;

    return-object v0
.end method


# virtual methods
.method public b()J
    .locals 2

    iget-wide v0, p0, Lio/flutter/embedding/android/v$a;->d:J

    return-wide v0
.end method
