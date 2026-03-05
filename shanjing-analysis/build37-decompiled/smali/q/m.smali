.class public final Lq/m;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lb0/a;
.implements Lc0/a;


# instance fields
.field private a:Lq/u;

.field private b:Lj0/k;

.field private c:Lc0/c;

.field private d:Lq/l;


# direct methods
.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private b()V
    .locals 2

    iget-object v0, p0, Lq/m;->c:Lc0/c;

    if-eqz v0, :cond_0

    iget-object v1, p0, Lq/m;->a:Lq/u;

    invoke-interface {v0, v1}, Lc0/c;->f(Lj0/m;)V

    iget-object v0, p0, Lq/m;->c:Lc0/c;

    iget-object v1, p0, Lq/m;->a:Lq/u;

    invoke-interface {v0, v1}, Lc0/c;->g(Lj0/o;)V

    :cond_0
    return-void
.end method

.method private e()V
    .locals 2

    iget-object v0, p0, Lq/m;->c:Lc0/c;

    if-eqz v0, :cond_0

    iget-object v1, p0, Lq/m;->a:Lq/u;

    invoke-interface {v0, v1}, Lc0/c;->h(Lj0/m;)V

    iget-object v0, p0, Lq/m;->c:Lc0/c;

    iget-object v1, p0, Lq/m;->a:Lq/u;

    invoke-interface {v0, v1}, Lc0/c;->e(Lj0/o;)V

    :cond_0
    return-void
.end method

.method private f(Landroid/content/Context;Lj0/c;)V
    .locals 3

    new-instance v0, Lj0/k;

    const-string v1, "flutter.baseflow.com/permissions/methods"

    invoke-direct {v0, p2, v1}, Lj0/k;-><init>(Lj0/c;Ljava/lang/String;)V

    iput-object v0, p0, Lq/m;->b:Lj0/k;

    new-instance p2, Lq/l;

    new-instance v0, Lq/a;

    invoke-direct {v0}, Lq/a;-><init>()V

    iget-object v1, p0, Lq/m;->a:Lq/u;

    new-instance v2, Lq/z;

    invoke-direct {v2}, Lq/z;-><init>()V

    invoke-direct {p2, p1, v0, v1, v2}, Lq/l;-><init>(Landroid/content/Context;Lq/a;Lq/u;Lq/z;)V

    iput-object p2, p0, Lq/m;->d:Lq/l;

    iget-object p1, p0, Lq/m;->b:Lj0/k;

    invoke-virtual {p1, p2}, Lj0/k;->e(Lj0/k$c;)V

    return-void
.end method

.method private j(Landroid/app/Activity;)V
    .locals 1

    iget-object v0, p0, Lq/m;->a:Lq/u;

    if-eqz v0, :cond_0

    invoke-virtual {v0, p1}, Lq/u;->j(Landroid/app/Activity;)V

    :cond_0
    return-void
.end method

.method private k()V
    .locals 2

    iget-object v0, p0, Lq/m;->b:Lj0/k;

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Lj0/k;->e(Lj0/k$c;)V

    iput-object v1, p0, Lq/m;->b:Lj0/k;

    iput-object v1, p0, Lq/m;->d:Lq/l;

    return-void
.end method

.method private l()V
    .locals 2

    iget-object v0, p0, Lq/m;->a:Lq/u;

    if-eqz v0, :cond_0

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Lq/u;->j(Landroid/app/Activity;)V

    :cond_0
    return-void
.end method


# virtual methods
.method public a(Lb0/a$b;)V
    .locals 0

    invoke-direct {p0}, Lq/m;->k()V

    return-void
.end method

.method public c()V
    .locals 1

    invoke-direct {p0}, Lq/m;->l()V

    invoke-direct {p0}, Lq/m;->b()V

    const/4 v0, 0x0

    iput-object v0, p0, Lq/m;->c:Lc0/c;

    return-void
.end method

.method public d(Lc0/c;)V
    .locals 1

    invoke-interface {p1}, Lc0/c;->d()Landroid/app/Activity;

    move-result-object v0

    invoke-direct {p0, v0}, Lq/m;->j(Landroid/app/Activity;)V

    iput-object p1, p0, Lq/m;->c:Lc0/c;

    invoke-direct {p0}, Lq/m;->e()V

    return-void
.end method

.method public g()V
    .locals 0

    invoke-virtual {p0}, Lq/m;->c()V

    return-void
.end method

.method public h(Lc0/c;)V
    .locals 0

    invoke-virtual {p0, p1}, Lq/m;->d(Lc0/c;)V

    return-void
.end method

.method public i(Lb0/a$b;)V
    .locals 2

    new-instance v0, Lq/u;

    invoke-virtual {p1}, Lb0/a$b;->a()Landroid/content/Context;

    move-result-object v1

    invoke-direct {v0, v1}, Lq/u;-><init>(Landroid/content/Context;)V

    iput-object v0, p0, Lq/m;->a:Lq/u;

    invoke-virtual {p1}, Lb0/a$b;->a()Landroid/content/Context;

    move-result-object v0

    invoke-virtual {p1}, Lb0/a$b;->b()Lj0/c;

    move-result-object p1

    invoke-direct {p0, v0, p1}, Lq/m;->f(Landroid/content/Context;Lj0/c;)V

    return-void
.end method
