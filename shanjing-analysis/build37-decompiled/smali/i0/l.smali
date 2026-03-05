.class public Li0/l;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Li0/l$g;,
        Li0/l$f;,
        Li0/l$b;,
        Li0/l$c;,
        Li0/l$e;,
        Li0/l$d;
    }
.end annotation


# instance fields
.field private final a:Lj0/k;

.field private b:Li0/l$g;

.field private final c:Lj0/k$c;


# direct methods
.method public constructor <init>(Lx/a;)V
    .locals 4

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    new-instance v0, Li0/l$a;

    invoke-direct {v0, p0}, Li0/l$a;-><init>(Li0/l;)V

    iput-object v0, p0, Li0/l;->c:Lj0/k$c;

    new-instance v1, Lj0/k;

    sget-object v2, Lj0/r;->b:Lj0/r;

    const-string v3, "flutter/platform_views"

    invoke-direct {v1, p1, v3, v2}, Lj0/k;-><init>(Lj0/c;Ljava/lang/String;Lj0/l;)V

    iput-object v1, p0, Li0/l;->a:Lj0/k;

    invoke-virtual {v1, v0}, Lj0/k;->e(Lj0/k$c;)V

    return-void
.end method

.method static synthetic a(Li0/l;)Li0/l$g;
    .locals 0

    iget-object p0, p0, Li0/l;->b:Li0/l$g;

    return-object p0
.end method

.method static synthetic b(Ljava/lang/Exception;)Ljava/lang/String;
    .locals 0

    invoke-static {p0}, Li0/l;->c(Ljava/lang/Exception;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method private static c(Ljava/lang/Exception;)Ljava/lang/String;
    .locals 0

    invoke-static {p0}, Lw/b;->d(Ljava/lang/Throwable;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method public d(I)V
    .locals 2

    iget-object v0, p0, Li0/l;->a:Lj0/k;

    if-nez v0, :cond_0

    return-void

    :cond_0
    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    const-string v1, "viewFocused"

    invoke-virtual {v0, v1, p1}, Lj0/k;->c(Ljava/lang/String;Ljava/lang/Object;)V

    return-void
.end method

.method public e(Li0/l$g;)V
    .locals 0

    iput-object p1, p0, Li0/l;->b:Li0/l$g;

    return-void
.end method
