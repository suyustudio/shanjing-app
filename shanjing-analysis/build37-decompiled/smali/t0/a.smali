.class public final enum Lt0/a;
.super Ljava/lang/Enum;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Enum<",
        "Lt0/a;",
        ">;"
    }
.end annotation


# static fields
.field public static final enum d:Lt0/a;

.field public static final enum e:Lt0/a;

.field public static final enum f:Lt0/a;

.field private static final synthetic g:[Lt0/a;

.field private static final synthetic h:Lu0/a;


# direct methods
.method static constructor <clinit>()V
    .locals 3

    new-instance v0, Lt0/a;

    const-string v1, "COROUTINE_SUSPENDED"

    const/4 v2, 0x0

    invoke-direct {v0, v1, v2}, Lt0/a;-><init>(Ljava/lang/String;I)V

    sput-object v0, Lt0/a;->d:Lt0/a;

    new-instance v0, Lt0/a;

    const-string v1, "UNDECIDED"

    const/4 v2, 0x1

    invoke-direct {v0, v1, v2}, Lt0/a;-><init>(Ljava/lang/String;I)V

    sput-object v0, Lt0/a;->e:Lt0/a;

    new-instance v0, Lt0/a;

    const-string v1, "RESUMED"

    const/4 v2, 0x2

    invoke-direct {v0, v1, v2}, Lt0/a;-><init>(Ljava/lang/String;I)V

    sput-object v0, Lt0/a;->f:Lt0/a;

    invoke-static {}, Lt0/a;->a()[Lt0/a;

    move-result-object v0

    sput-object v0, Lt0/a;->g:[Lt0/a;

    invoke-static {v0}, Lu0/b;->a([Ljava/lang/Enum;)Lu0/a;

    move-result-object v0

    sput-object v0, Lt0/a;->h:Lu0/a;

    return-void
.end method

.method private constructor <init>(Ljava/lang/String;I)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    invoke-direct {p0, p1, p2}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    return-void
.end method

.method private static final synthetic a()[Lt0/a;
    .locals 3

    const/4 v0, 0x3

    new-array v0, v0, [Lt0/a;

    sget-object v1, Lt0/a;->d:Lt0/a;

    const/4 v2, 0x0

    aput-object v1, v0, v2

    sget-object v1, Lt0/a;->e:Lt0/a;

    const/4 v2, 0x1

    aput-object v1, v0, v2

    sget-object v1, Lt0/a;->f:Lt0/a;

    const/4 v2, 0x2

    aput-object v1, v0, v2

    return-object v0
.end method

.method public static valueOf(Ljava/lang/String;)Lt0/a;
    .locals 1

    const-class v0, Lt0/a;

    invoke-static {v0, p0}, Ljava/lang/Enum;->valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;

    move-result-object p0

    check-cast p0, Lt0/a;

    return-object p0
.end method

.method public static values()[Lt0/a;
    .locals 1

    sget-object v0, Lt0/a;->g:[Lt0/a;

    invoke-virtual {v0}, [Ljava/lang/Object;->clone()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Lt0/a;

    return-object v0
.end method
