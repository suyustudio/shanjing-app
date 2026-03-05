.class public Li0/n;
.super Ljava/lang/Object;
.source "SourceFile"


# instance fields
.field public final a:Z

.field private b:[B

.field private c:Lj0/k;

.field private d:Lj0/k$d;

.field private e:Z

.field private f:Z

.field private final g:Lj0/k$c;


# direct methods
.method constructor <init>(Lj0/k;Z)V
    .locals 1

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    const/4 v0, 0x0

    iput-boolean v0, p0, Li0/n;->e:Z

    iput-boolean v0, p0, Li0/n;->f:Z

    new-instance v0, Li0/n$b;

    invoke-direct {v0, p0}, Li0/n$b;-><init>(Li0/n;)V

    iput-object v0, p0, Li0/n;->g:Lj0/k$c;

    iput-object p1, p0, Li0/n;->c:Lj0/k;

    iput-boolean p2, p0, Li0/n;->a:Z

    invoke-virtual {p1, v0}, Lj0/k;->e(Lj0/k$c;)V

    return-void
.end method

.method public constructor <init>(Lx/a;Z)V
    .locals 3

    new-instance v0, Lj0/k;

    sget-object v1, Lj0/r;->b:Lj0/r;

    const-string v2, "flutter/restoration"

    invoke-direct {v0, p1, v2, v1}, Lj0/k;-><init>(Lj0/c;Ljava/lang/String;Lj0/l;)V

    invoke-direct {p0, v0, p2}, Li0/n;-><init>(Lj0/k;Z)V

    return-void
.end method

.method static synthetic a(Li0/n;)[B
    .locals 0

    iget-object p0, p0, Li0/n;->b:[B

    return-object p0
.end method

.method static synthetic b(Li0/n;[B)[B
    .locals 0

    iput-object p1, p0, Li0/n;->b:[B

    return-object p1
.end method

.method static synthetic c(Li0/n;Z)Z
    .locals 0

    iput-boolean p1, p0, Li0/n;->f:Z

    return p1
.end method

.method static synthetic d(Li0/n;)Z
    .locals 0

    iget-boolean p0, p0, Li0/n;->e:Z

    return p0
.end method

.method static synthetic e(Li0/n;[B)Ljava/util/Map;
    .locals 0

    invoke-direct {p0, p1}, Li0/n;->i([B)Ljava/util/Map;

    move-result-object p0

    return-object p0
.end method

.method static synthetic f(Li0/n;Lj0/k$d;)Lj0/k$d;
    .locals 0

    iput-object p1, p0, Li0/n;->d:Lj0/k$d;

    return-object p1
.end method

.method private i([B)Ljava/util/Map;
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "([B)",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/Object;",
            ">;"
        }
    .end annotation

    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    sget-object v1, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    const-string v2, "enabled"

    invoke-interface {v0, v2, v1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    const-string v1, "data"

    invoke-interface {v0, v1, p1}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    return-object v0
.end method


# virtual methods
.method public g()V
    .locals 1

    const/4 v0, 0x0

    iput-object v0, p0, Li0/n;->b:[B

    return-void
.end method

.method public h()[B
    .locals 1

    iget-object v0, p0, Li0/n;->b:[B

    return-object v0
.end method

.method public j([B)V
    .locals 3

    const/4 v0, 0x1

    iput-boolean v0, p0, Li0/n;->e:Z

    iget-object v0, p0, Li0/n;->d:Lj0/k$d;

    if-eqz v0, :cond_1

    invoke-direct {p0, p1}, Li0/n;->i([B)Ljava/util/Map;

    move-result-object v1

    invoke-interface {v0, v1}, Lj0/k$d;->a(Ljava/lang/Object;)V

    const/4 v0, 0x0

    iput-object v0, p0, Li0/n;->d:Lj0/k$d;

    :cond_0
    iput-object p1, p0, Li0/n;->b:[B

    goto :goto_0

    :cond_1
    iget-boolean v0, p0, Li0/n;->f:Z

    if-eqz v0, :cond_0

    iget-object v0, p0, Li0/n;->c:Lj0/k;

    invoke-direct {p0, p1}, Li0/n;->i([B)Ljava/util/Map;

    move-result-object v1

    new-instance v2, Li0/n$a;

    invoke-direct {v2, p0, p1}, Li0/n$a;-><init>(Li0/n;[B)V

    const-string p1, "push"

    invoke-virtual {v0, p1, v1, v2}, Lj0/k;->d(Ljava/lang/String;Ljava/lang/Object;Lj0/k$d;)V

    :goto_0
    return-void
.end method
