.class public final enum Le1/g;
.super Ljava/lang/Enum;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Enum<",
        "Le1/g;",
        ">;"
    }
.end annotation


# static fields
.field public static final enum d:Le1/g;

.field public static final enum e:Le1/g;

.field public static final enum f:Le1/g;

.field public static final enum g:Le1/g;

.field private static final synthetic h:[Le1/g;

.field private static final synthetic i:Lu0/a;


# direct methods
.method static constructor <clinit>()V
    .locals 3

    new-instance v0, Le1/g;

    const-string v1, "PUBLIC"

    const/4 v2, 0x0

    invoke-direct {v0, v1, v2}, Le1/g;-><init>(Ljava/lang/String;I)V

    sput-object v0, Le1/g;->d:Le1/g;

    new-instance v0, Le1/g;

    const-string v1, "PROTECTED"

    const/4 v2, 0x1

    invoke-direct {v0, v1, v2}, Le1/g;-><init>(Ljava/lang/String;I)V

    sput-object v0, Le1/g;->e:Le1/g;

    new-instance v0, Le1/g;

    const-string v1, "INTERNAL"

    const/4 v2, 0x2

    invoke-direct {v0, v1, v2}, Le1/g;-><init>(Ljava/lang/String;I)V

    sput-object v0, Le1/g;->f:Le1/g;

    new-instance v0, Le1/g;

    const-string v1, "PRIVATE"

    const/4 v2, 0x3

    invoke-direct {v0, v1, v2}, Le1/g;-><init>(Ljava/lang/String;I)V

    sput-object v0, Le1/g;->g:Le1/g;

    invoke-static {}, Le1/g;->a()[Le1/g;

    move-result-object v0

    sput-object v0, Le1/g;->h:[Le1/g;

    invoke-static {v0}, Lu0/b;->a([Ljava/lang/Enum;)Lu0/a;

    move-result-object v0

    sput-object v0, Le1/g;->i:Lu0/a;

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

.method private static final synthetic a()[Le1/g;
    .locals 3

    const/4 v0, 0x4

    new-array v0, v0, [Le1/g;

    sget-object v1, Le1/g;->d:Le1/g;

    const/4 v2, 0x0

    aput-object v1, v0, v2

    sget-object v1, Le1/g;->e:Le1/g;

    const/4 v2, 0x1

    aput-object v1, v0, v2

    sget-object v1, Le1/g;->f:Le1/g;

    const/4 v2, 0x2

    aput-object v1, v0, v2

    sget-object v1, Le1/g;->g:Le1/g;

    const/4 v2, 0x3

    aput-object v1, v0, v2

    return-object v0
.end method

.method public static valueOf(Ljava/lang/String;)Le1/g;
    .locals 1

    const-class v0, Le1/g;

    invoke-static {v0, p0}, Ljava/lang/Enum;->valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;

    move-result-object p0

    check-cast p0, Le1/g;

    return-object p0
.end method

.method public static values()[Le1/g;
    .locals 1

    sget-object v0, Le1/g;->h:[Le1/g;

    invoke-virtual {v0}, [Ljava/lang/Object;->clone()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Le1/g;

    return-object v0
.end method
