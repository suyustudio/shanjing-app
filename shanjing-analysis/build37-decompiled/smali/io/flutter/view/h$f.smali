.class final enum Lio/flutter/view/h$f;
.super Ljava/lang/Enum;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lio/flutter/view/h;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x401a
    name = "f"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Enum<",
        "Lio/flutter/view/h$f;",
        ">;"
    }
.end annotation


# static fields
.field public static final enum e:Lio/flutter/view/h$f;

.field public static final enum f:Lio/flutter/view/h$f;

.field public static final enum g:Lio/flutter/view/h$f;

.field public static final enum h:Lio/flutter/view/h$f;

.field public static final enum i:Lio/flutter/view/h$f;

.field public static final enum j:Lio/flutter/view/h$f;

.field public static final enum k:Lio/flutter/view/h$f;

.field private static final synthetic l:[Lio/flutter/view/h$f;


# instance fields
.field final d:I


# direct methods
.method static constructor <clinit>()V
    .locals 5

    new-instance v0, Lio/flutter/view/h$f;

    const-string v1, "ACCESSIBLE_NAVIGATION"

    const/4 v2, 0x0

    const/4 v3, 0x1

    invoke-direct {v0, v1, v2, v3}, Lio/flutter/view/h$f;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/view/h$f;->e:Lio/flutter/view/h$f;

    new-instance v0, Lio/flutter/view/h$f;

    const-string v1, "INVERT_COLORS"

    const/4 v2, 0x2

    invoke-direct {v0, v1, v3, v2}, Lio/flutter/view/h$f;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/view/h$f;->f:Lio/flutter/view/h$f;

    new-instance v0, Lio/flutter/view/h$f;

    const-string v1, "DISABLE_ANIMATIONS"

    const/4 v3, 0x4

    invoke-direct {v0, v1, v2, v3}, Lio/flutter/view/h$f;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/view/h$f;->g:Lio/flutter/view/h$f;

    new-instance v0, Lio/flutter/view/h$f;

    const-string v1, "BOLD_TEXT"

    const/4 v2, 0x3

    const/16 v4, 0x8

    invoke-direct {v0, v1, v2, v4}, Lio/flutter/view/h$f;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/view/h$f;->h:Lio/flutter/view/h$f;

    new-instance v0, Lio/flutter/view/h$f;

    const-string v1, "REDUCE_MOTION"

    const/16 v2, 0x10

    invoke-direct {v0, v1, v3, v2}, Lio/flutter/view/h$f;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/view/h$f;->i:Lio/flutter/view/h$f;

    new-instance v0, Lio/flutter/view/h$f;

    const-string v1, "HIGH_CONTRAST"

    const/4 v2, 0x5

    const/16 v3, 0x20

    invoke-direct {v0, v1, v2, v3}, Lio/flutter/view/h$f;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/view/h$f;->j:Lio/flutter/view/h$f;

    new-instance v0, Lio/flutter/view/h$f;

    const-string v1, "ON_OFF_SWITCH_LABELS"

    const/4 v2, 0x6

    const/16 v3, 0x40

    invoke-direct {v0, v1, v2, v3}, Lio/flutter/view/h$f;-><init>(Ljava/lang/String;II)V

    sput-object v0, Lio/flutter/view/h$f;->k:Lio/flutter/view/h$f;

    invoke-static {}, Lio/flutter/view/h$f;->a()[Lio/flutter/view/h$f;

    move-result-object v0

    sput-object v0, Lio/flutter/view/h$f;->l:[Lio/flutter/view/h$f;

    return-void
.end method

.method private constructor <init>(Ljava/lang/String;II)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(I)V"
        }
    .end annotation

    invoke-direct {p0, p1, p2}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    iput p3, p0, Lio/flutter/view/h$f;->d:I

    return-void
.end method

.method private static synthetic a()[Lio/flutter/view/h$f;
    .locals 3

    const/4 v0, 0x7

    new-array v0, v0, [Lio/flutter/view/h$f;

    sget-object v1, Lio/flutter/view/h$f;->e:Lio/flutter/view/h$f;

    const/4 v2, 0x0

    aput-object v1, v0, v2

    sget-object v1, Lio/flutter/view/h$f;->f:Lio/flutter/view/h$f;

    const/4 v2, 0x1

    aput-object v1, v0, v2

    sget-object v1, Lio/flutter/view/h$f;->g:Lio/flutter/view/h$f;

    const/4 v2, 0x2

    aput-object v1, v0, v2

    sget-object v1, Lio/flutter/view/h$f;->h:Lio/flutter/view/h$f;

    const/4 v2, 0x3

    aput-object v1, v0, v2

    sget-object v1, Lio/flutter/view/h$f;->i:Lio/flutter/view/h$f;

    const/4 v2, 0x4

    aput-object v1, v0, v2

    sget-object v1, Lio/flutter/view/h$f;->j:Lio/flutter/view/h$f;

    const/4 v2, 0x5

    aput-object v1, v0, v2

    sget-object v1, Lio/flutter/view/h$f;->k:Lio/flutter/view/h$f;

    const/4 v2, 0x6

    aput-object v1, v0, v2

    return-object v0
.end method

.method public static valueOf(Ljava/lang/String;)Lio/flutter/view/h$f;
    .locals 1

    const-class v0, Lio/flutter/view/h$f;

    invoke-static {v0, p0}, Ljava/lang/Enum;->valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;

    move-result-object p0

    check-cast p0, Lio/flutter/view/h$f;

    return-object p0
.end method

.method public static values()[Lio/flutter/view/h$f;
    .locals 1

    sget-object v0, Lio/flutter/view/h$f;->l:[Lio/flutter/view/h$f;

    invoke-virtual {v0}, [Lio/flutter/view/h$f;->clone()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Lio/flutter/view/h$f;

    return-object v0
.end method
