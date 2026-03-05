.class public Landroidx/core/view/t;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Landroidx/core/view/t$a;,
        Landroidx/core/view/t$n;,
        Landroidx/core/view/t$m;,
        Landroidx/core/view/t$e;,
        Landroidx/core/view/t$d;,
        Landroidx/core/view/t$c;,
        Landroidx/core/view/t$f;,
        Landroidx/core/view/t$b;,
        Landroidx/core/view/t$k;,
        Landroidx/core/view/t$j;,
        Landroidx/core/view/t$i;,
        Landroidx/core/view/t$h;,
        Landroidx/core/view/t$g;,
        Landroidx/core/view/t$l;
    }
.end annotation


# static fields
.field public static final b:Landroidx/core/view/t;


# instance fields
.field private final a:Landroidx/core/view/t$l;


# direct methods
.method static constructor <clinit>()V
    .locals 2

    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1e

    if-lt v0, v1, :cond_0

    sget-object v0, Landroidx/core/view/t$k;->q:Landroidx/core/view/t;

    goto :goto_0

    :cond_0
    sget-object v0, Landroidx/core/view/t$l;->b:Landroidx/core/view/t;

    :goto_0
    sput-object v0, Landroidx/core/view/t;->b:Landroidx/core/view/t;

    return-void
.end method

.method private constructor <init>(Landroid/view/WindowInsets;)V
    .locals 2

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1e

    if-lt v0, v1, :cond_0

    new-instance v0, Landroidx/core/view/t$k;

    invoke-direct {v0, p0, p1}, Landroidx/core/view/t$k;-><init>(Landroidx/core/view/t;Landroid/view/WindowInsets;)V

    :goto_0
    iput-object v0, p0, Landroidx/core/view/t;->a:Landroidx/core/view/t$l;

    goto :goto_1

    :cond_0
    const/16 v1, 0x1d

    if-lt v0, v1, :cond_1

    new-instance v0, Landroidx/core/view/t$j;

    invoke-direct {v0, p0, p1}, Landroidx/core/view/t$j;-><init>(Landroidx/core/view/t;Landroid/view/WindowInsets;)V

    goto :goto_0

    :cond_1
    const/16 v1, 0x1c

    if-lt v0, v1, :cond_2

    new-instance v0, Landroidx/core/view/t$i;

    invoke-direct {v0, p0, p1}, Landroidx/core/view/t$i;-><init>(Landroidx/core/view/t;Landroid/view/WindowInsets;)V

    goto :goto_0

    :cond_2
    new-instance v0, Landroidx/core/view/t$h;

    invoke-direct {v0, p0, p1}, Landroidx/core/view/t$h;-><init>(Landroidx/core/view/t;Landroid/view/WindowInsets;)V

    goto :goto_0

    :goto_1
    return-void
.end method

.method public constructor <init>(Landroidx/core/view/t;)V
    .locals 2

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    if-eqz p1, :cond_5

    iget-object p1, p1, Landroidx/core/view/t;->a:Landroidx/core/view/t$l;

    sget v0, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v1, 0x1e

    if-lt v0, v1, :cond_0

    instance-of v1, p1, Landroidx/core/view/t$k;

    if-eqz v1, :cond_0

    new-instance v0, Landroidx/core/view/t$k;

    move-object v1, p1

    check-cast v1, Landroidx/core/view/t$k;

    invoke-direct {v0, p0, v1}, Landroidx/core/view/t$k;-><init>(Landroidx/core/view/t;Landroidx/core/view/t$k;)V

    :goto_0
    iput-object v0, p0, Landroidx/core/view/t;->a:Landroidx/core/view/t$l;

    goto :goto_1

    :cond_0
    const/16 v1, 0x1d

    if-lt v0, v1, :cond_1

    instance-of v1, p1, Landroidx/core/view/t$j;

    if-eqz v1, :cond_1

    new-instance v0, Landroidx/core/view/t$j;

    move-object v1, p1

    check-cast v1, Landroidx/core/view/t$j;

    invoke-direct {v0, p0, v1}, Landroidx/core/view/t$j;-><init>(Landroidx/core/view/t;Landroidx/core/view/t$j;)V

    goto :goto_0

    :cond_1
    const/16 v1, 0x1c

    if-lt v0, v1, :cond_2

    instance-of v0, p1, Landroidx/core/view/t$i;

    if-eqz v0, :cond_2

    new-instance v0, Landroidx/core/view/t$i;

    move-object v1, p1

    check-cast v1, Landroidx/core/view/t$i;

    invoke-direct {v0, p0, v1}, Landroidx/core/view/t$i;-><init>(Landroidx/core/view/t;Landroidx/core/view/t$i;)V

    goto :goto_0

    :cond_2
    instance-of v0, p1, Landroidx/core/view/t$h;

    if-eqz v0, :cond_3

    new-instance v0, Landroidx/core/view/t$h;

    move-object v1, p1

    check-cast v1, Landroidx/core/view/t$h;

    invoke-direct {v0, p0, v1}, Landroidx/core/view/t$h;-><init>(Landroidx/core/view/t;Landroidx/core/view/t$h;)V

    goto :goto_0

    :cond_3
    instance-of v0, p1, Landroidx/core/view/t$g;

    if-eqz v0, :cond_4

    new-instance v0, Landroidx/core/view/t$g;

    move-object v1, p1

    check-cast v1, Landroidx/core/view/t$g;

    invoke-direct {v0, p0, v1}, Landroidx/core/view/t$g;-><init>(Landroidx/core/view/t;Landroidx/core/view/t$g;)V

    goto :goto_0

    :cond_4
    new-instance v0, Landroidx/core/view/t$l;

    invoke-direct {v0, p0}, Landroidx/core/view/t$l;-><init>(Landroidx/core/view/t;)V

    goto :goto_0

    :goto_1
    invoke-virtual {p1, p0}, Landroidx/core/view/t$l;->e(Landroidx/core/view/t;)V

    goto :goto_2

    :cond_5
    new-instance p1, Landroidx/core/view/t$l;

    invoke-direct {p1, p0}, Landroidx/core/view/t$l;-><init>(Landroidx/core/view/t;)V

    iput-object p1, p0, Landroidx/core/view/t;->a:Landroidx/core/view/t$l;

    :goto_2
    return-void
.end method

.method public static n(Landroid/view/WindowInsets;)Landroidx/core/view/t;
    .locals 1

    const/4 v0, 0x0

    invoke-static {p0, v0}, Landroidx/core/view/t;->o(Landroid/view/WindowInsets;Landroid/view/View;)Landroidx/core/view/t;

    move-result-object p0

    return-object p0
.end method

.method public static o(Landroid/view/WindowInsets;Landroid/view/View;)Landroidx/core/view/t;
    .locals 1

    new-instance v0, Landroidx/core/view/t;

    invoke-static {p0}, Landroidx/core/util/c;->a(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Landroid/view/WindowInsets;

    invoke-direct {v0, p0}, Landroidx/core/view/t;-><init>(Landroid/view/WindowInsets;)V

    if-eqz p1, :cond_0

    invoke-static {p1}, Landroidx/core/view/e;->e(Landroid/view/View;)Z

    move-result p0

    if-eqz p0, :cond_0

    invoke-static {p1}, Landroidx/core/view/e;->d(Landroid/view/View;)Landroidx/core/view/t;

    move-result-object p0

    invoke-virtual {v0, p0}, Landroidx/core/view/t;->k(Landroidx/core/view/t;)V

    invoke-virtual {p1}, Landroid/view/View;->getRootView()Landroid/view/View;

    move-result-object p0

    invoke-virtual {v0, p0}, Landroidx/core/view/t;->d(Landroid/view/View;)V

    :cond_0
    return-object v0
.end method


# virtual methods
.method public a()Landroidx/core/view/t;
    .locals 1
    .annotation runtime Ljava/lang/Deprecated;
    .end annotation

    iget-object v0, p0, Landroidx/core/view/t;->a:Landroidx/core/view/t$l;

    invoke-virtual {v0}, Landroidx/core/view/t$l;->a()Landroidx/core/view/t;

    move-result-object v0

    return-object v0
.end method

.method public b()Landroidx/core/view/t;
    .locals 1
    .annotation runtime Ljava/lang/Deprecated;
    .end annotation

    iget-object v0, p0, Landroidx/core/view/t;->a:Landroidx/core/view/t$l;

    invoke-virtual {v0}, Landroidx/core/view/t$l;->b()Landroidx/core/view/t;

    move-result-object v0

    return-object v0
.end method

.method public c()Landroidx/core/view/t;
    .locals 1
    .annotation runtime Ljava/lang/Deprecated;
    .end annotation

    iget-object v0, p0, Landroidx/core/view/t;->a:Landroidx/core/view/t$l;

    invoke-virtual {v0}, Landroidx/core/view/t$l;->c()Landroidx/core/view/t;

    move-result-object v0

    return-object v0
.end method

.method d(Landroid/view/View;)V
    .locals 1

    iget-object v0, p0, Landroidx/core/view/t;->a:Landroidx/core/view/t$l;

    invoke-virtual {v0, p1}, Landroidx/core/view/t$l;->d(Landroid/view/View;)V

    return-void
.end method

.method public e()Landroidx/core/view/a;
    .locals 1

    iget-object v0, p0, Landroidx/core/view/t;->a:Landroidx/core/view/t$l;

    invoke-virtual {v0}, Landroidx/core/view/t$l;->f()Landroidx/core/view/a;

    move-result-object v0

    return-object v0
.end method

.method public equals(Ljava/lang/Object;)Z
    .locals 1

    if-ne p0, p1, :cond_0

    const/4 p1, 0x1

    return p1

    :cond_0
    instance-of v0, p1, Landroidx/core/view/t;

    if-nez v0, :cond_1

    const/4 p1, 0x0

    return p1

    :cond_1
    check-cast p1, Landroidx/core/view/t;

    iget-object v0, p0, Landroidx/core/view/t;->a:Landroidx/core/view/t$l;

    iget-object p1, p1, Landroidx/core/view/t;->a:Landroidx/core/view/t$l;

    invoke-static {v0, p1}, Landroidx/core/util/b;->a(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p1

    return p1
.end method

.method public f(I)Landroidx/core/graphics/a;
    .locals 1

    iget-object v0, p0, Landroidx/core/view/t;->a:Landroidx/core/view/t$l;

    invoke-virtual {v0, p1}, Landroidx/core/view/t$l;->g(I)Landroidx/core/graphics/a;

    move-result-object p1

    return-object p1
.end method

.method public g()Landroidx/core/graphics/a;
    .locals 1
    .annotation runtime Ljava/lang/Deprecated;
    .end annotation

    iget-object v0, p0, Landroidx/core/view/t;->a:Landroidx/core/view/t$l;

    invoke-virtual {v0}, Landroidx/core/view/t$l;->i()Landroidx/core/graphics/a;

    move-result-object v0

    return-object v0
.end method

.method public h(I)Z
    .locals 1

    iget-object v0, p0, Landroidx/core/view/t;->a:Landroidx/core/view/t$l;

    invoke-virtual {v0, p1}, Landroidx/core/view/t$l;->o(I)Z

    move-result p1

    return p1
.end method

.method public hashCode()I
    .locals 1

    iget-object v0, p0, Landroidx/core/view/t;->a:Landroidx/core/view/t$l;

    if-nez v0, :cond_0

    const/4 v0, 0x0

    goto :goto_0

    :cond_0
    invoke-virtual {v0}, Landroidx/core/view/t$l;->hashCode()I

    move-result v0

    :goto_0
    return v0
.end method

.method i([Landroidx/core/graphics/a;)V
    .locals 1

    iget-object v0, p0, Landroidx/core/view/t;->a:Landroidx/core/view/t$l;

    invoke-virtual {v0, p1}, Landroidx/core/view/t$l;->p([Landroidx/core/graphics/a;)V

    return-void
.end method

.method j(Landroidx/core/graphics/a;)V
    .locals 1

    iget-object v0, p0, Landroidx/core/view/t;->a:Landroidx/core/view/t$l;

    invoke-virtual {v0, p1}, Landroidx/core/view/t$l;->q(Landroidx/core/graphics/a;)V

    return-void
.end method

.method k(Landroidx/core/view/t;)V
    .locals 1

    iget-object v0, p0, Landroidx/core/view/t;->a:Landroidx/core/view/t$l;

    invoke-virtual {v0, p1}, Landroidx/core/view/t$l;->r(Landroidx/core/view/t;)V

    return-void
.end method

.method l(Landroidx/core/graphics/a;)V
    .locals 1

    iget-object v0, p0, Landroidx/core/view/t;->a:Landroidx/core/view/t$l;

    invoke-virtual {v0, p1}, Landroidx/core/view/t$l;->s(Landroidx/core/graphics/a;)V

    return-void
.end method

.method public m()Landroid/view/WindowInsets;
    .locals 2

    iget-object v0, p0, Landroidx/core/view/t;->a:Landroidx/core/view/t$l;

    instance-of v1, v0, Landroidx/core/view/t$g;

    if-eqz v1, :cond_0

    check-cast v0, Landroidx/core/view/t$g;

    iget-object v0, v0, Landroidx/core/view/t$g;->c:Landroid/view/WindowInsets;

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return-object v0
.end method
