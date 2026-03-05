.class public final Lh1/s0;
.super Ljava/lang/Object;
.source "SourceFile"


# static fields
.field public static final a:Lh1/s0;

.field private static final b:Lh1/f0;

.field private static final c:Lh1/f0;

.field private static final d:Lh1/f0;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    new-instance v0, Lh1/s0;

    invoke-direct {v0}, Lh1/s0;-><init>()V

    sput-object v0, Lh1/s0;->a:Lh1/s0;

    invoke-static {}, Lh1/e0;->a()Lh1/f0;

    move-result-object v0

    sput-object v0, Lh1/s0;->b:Lh1/f0;

    sget-object v0, Lh1/c2;->e:Lh1/c2;

    sput-object v0, Lh1/s0;->c:Lh1/f0;

    sget-object v0, Lkotlinx/coroutines/scheduling/b;->k:Lkotlinx/coroutines/scheduling/b;

    invoke-virtual {v0}, Lkotlinx/coroutines/scheduling/b;->r()Lh1/f0;

    move-result-object v0

    sput-object v0, Lh1/s0;->d:Lh1/f0;

    return-void
.end method

.method private constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static final a()Lh1/f0;
    .locals 1

    sget-object v0, Lh1/s0;->b:Lh1/f0;

    return-object v0
.end method

.method public static final b()Lh1/f0;
    .locals 1

    sget-object v0, Lh1/s0;->d:Lh1/f0;

    return-object v0
.end method

.method public static final c()Lh1/u1;
    .locals 1

    sget-object v0, Lkotlinx/coroutines/internal/p;->c:Lh1/u1;

    return-object v0
.end method
