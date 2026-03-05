.class public Lv/h;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lb0/a;


# instance fields
.field private a:Lj0/k;

.field private b:Lj0/d;

.field private c:Lv/f;


# direct methods
.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private b(Lj0/c;Landroid/content/Context;)V
    .locals 2

    new-instance v0, Lj0/k;

    const-string v1, "dev.fluttercommunity.plus/connectivity"

    invoke-direct {v0, p1, v1}, Lj0/k;-><init>(Lj0/c;Ljava/lang/String;)V

    iput-object v0, p0, Lv/h;->a:Lj0/k;

    new-instance v0, Lj0/d;

    const-string v1, "dev.fluttercommunity.plus/connectivity_status"

    invoke-direct {v0, p1, v1}, Lj0/d;-><init>(Lj0/c;Ljava/lang/String;)V

    iput-object v0, p0, Lv/h;->b:Lj0/d;

    const-string p1, "connectivity"

    invoke-virtual {p2, p1}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Landroid/net/ConnectivityManager;

    new-instance v0, Lv/b;

    invoke-direct {v0, p1}, Lv/b;-><init>(Landroid/net/ConnectivityManager;)V

    new-instance p1, Lv/g;

    invoke-direct {p1, v0}, Lv/g;-><init>(Lv/b;)V

    new-instance v1, Lv/f;

    invoke-direct {v1, p2, v0}, Lv/f;-><init>(Landroid/content/Context;Lv/b;)V

    iput-object v1, p0, Lv/h;->c:Lv/f;

    iget-object p2, p0, Lv/h;->a:Lj0/k;

    invoke-virtual {p2, p1}, Lj0/k;->e(Lj0/k$c;)V

    iget-object p1, p0, Lv/h;->b:Lj0/d;

    iget-object p2, p0, Lv/h;->c:Lv/f;

    invoke-virtual {p1, p2}, Lj0/d;->d(Lj0/d$d;)V

    return-void
.end method

.method private c()V
    .locals 2

    iget-object v0, p0, Lv/h;->a:Lj0/k;

    const/4 v1, 0x0

    invoke-virtual {v0, v1}, Lj0/k;->e(Lj0/k$c;)V

    iget-object v0, p0, Lv/h;->b:Lj0/d;

    invoke-virtual {v0, v1}, Lj0/d;->d(Lj0/d$d;)V

    iget-object v0, p0, Lv/h;->c:Lv/f;

    invoke-virtual {v0, v1}, Lv/f;->b(Ljava/lang/Object;)V

    iput-object v1, p0, Lv/h;->a:Lj0/k;

    iput-object v1, p0, Lv/h;->b:Lj0/d;

    iput-object v1, p0, Lv/h;->c:Lv/f;

    return-void
.end method


# virtual methods
.method public a(Lb0/a$b;)V
    .locals 0

    invoke-direct {p0}, Lv/h;->c()V

    return-void
.end method

.method public i(Lb0/a$b;)V
    .locals 1

    invoke-virtual {p1}, Lb0/a$b;->b()Lj0/c;

    move-result-object v0

    invoke-virtual {p1}, Lb0/a$b;->a()Landroid/content/Context;

    move-result-object p1

    invoke-direct {p0, v0, p1}, Lv/h;->b(Lj0/c;Landroid/content/Context;)V

    return-void
.end method
