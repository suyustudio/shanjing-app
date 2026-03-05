.class public final Ld1/c$a;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Ld1/c;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "a"
.end annotation


# direct methods
.method private constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public synthetic constructor <init>(Lkotlin/jvm/internal/e;)V
    .locals 0

    invoke-direct {p0}, Ld1/c$a;-><init>()V

    return-void
.end method


# virtual methods
.method public final a()Ld1/c;
    .locals 1

    invoke-static {}, Ld1/c;->e()Ld1/c;

    move-result-object v0

    return-object v0
.end method
