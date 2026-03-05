.class public final enum Li0/o$c;
.super Ljava/lang/Enum;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Li0/o;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x4019
    name = "c"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Enum<",
        "Li0/o$c;",
        ">;"
    }
.end annotation


# static fields
.field public static final enum e:Li0/o$c;

.field public static final enum f:Li0/o$c;

.field private static final synthetic g:[Li0/o$c;


# instance fields
.field public d:Ljava/lang/String;


# direct methods
.method static constructor <clinit>()V
    .locals 3

    new-instance v0, Li0/o$c;

    const-string v1, "light"

    const/4 v2, 0x0

    invoke-direct {v0, v1, v2, v1}, Li0/o$c;-><init>(Ljava/lang/String;ILjava/lang/String;)V

    sput-object v0, Li0/o$c;->e:Li0/o$c;

    new-instance v0, Li0/o$c;

    const-string v1, "dark"

    const/4 v2, 0x1

    invoke-direct {v0, v1, v2, v1}, Li0/o$c;-><init>(Ljava/lang/String;ILjava/lang/String;)V

    sput-object v0, Li0/o$c;->f:Li0/o$c;

    invoke-static {}, Li0/o$c;->a()[Li0/o$c;

    move-result-object v0

    sput-object v0, Li0/o$c;->g:[Li0/o$c;

    return-void
.end method

.method private constructor <init>(Ljava/lang/String;ILjava/lang/String;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/String;",
            ")V"
        }
    .end annotation

    invoke-direct {p0, p1, p2}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    iput-object p3, p0, Li0/o$c;->d:Ljava/lang/String;

    return-void
.end method

.method private static synthetic a()[Li0/o$c;
    .locals 3

    const/4 v0, 0x2

    new-array v0, v0, [Li0/o$c;

    sget-object v1, Li0/o$c;->e:Li0/o$c;

    const/4 v2, 0x0

    aput-object v1, v0, v2

    sget-object v1, Li0/o$c;->f:Li0/o$c;

    const/4 v2, 0x1

    aput-object v1, v0, v2

    return-object v0
.end method

.method public static valueOf(Ljava/lang/String;)Li0/o$c;
    .locals 1

    const-class v0, Li0/o$c;

    invoke-static {v0, p0}, Ljava/lang/Enum;->valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;

    move-result-object p0

    check-cast p0, Li0/o$c;

    return-object p0
.end method

.method public static values()[Li0/o$c;
    .locals 1

    sget-object v0, Li0/o$c;->g:[Li0/o$c;

    invoke-virtual {v0}, [Li0/o$c;->clone()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Li0/o$c;

    return-object v0
.end method
