.class public Li0/b;
.super Ljava/lang/Object;
.source "SourceFile"


# instance fields
.field private final a:Lj0/k;

.field private b:Ly/a;

.field private c:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/util/List<",
            "Lj0/k$d;",
            ">;>;"
        }
    .end annotation
.end field

.field final d:Lj0/k$c;


# direct methods
.method public constructor <init>(Lx/a;)V
    .locals 4

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    new-instance v0, Li0/b$a;

    invoke-direct {v0, p0}, Li0/b$a;-><init>(Li0/b;)V

    iput-object v0, p0, Li0/b;->d:Lj0/k$c;

    new-instance v1, Lj0/k;

    sget-object v2, Lj0/r;->b:Lj0/r;

    const-string v3, "flutter/deferredcomponent"

    invoke-direct {v1, p1, v3, v2}, Lj0/k;-><init>(Lj0/c;Ljava/lang/String;Lj0/l;)V

    iput-object v1, p0, Li0/b;->a:Lj0/k;

    invoke-virtual {v1, v0}, Lj0/k;->e(Lj0/k$c;)V

    invoke-static {}, Lw/a;->e()Lw/a;

    move-result-object p1

    invoke-virtual {p1}, Lw/a;->a()Ly/a;

    move-result-object p1

    iput-object p1, p0, Li0/b;->b:Ly/a;

    new-instance p1, Ljava/util/HashMap;

    invoke-direct {p1}, Ljava/util/HashMap;-><init>()V

    iput-object p1, p0, Li0/b;->c:Ljava/util/Map;

    return-void
.end method

.method static synthetic a(Li0/b;)Ly/a;
    .locals 0

    iget-object p0, p0, Li0/b;->b:Ly/a;

    return-object p0
.end method

.method static synthetic b(Li0/b;)Ljava/util/Map;
    .locals 0

    iget-object p0, p0, Li0/b;->c:Ljava/util/Map;

    return-object p0
.end method


# virtual methods
.method public c(Ly/a;)V
    .locals 0

    iput-object p1, p0, Li0/b;->b:Ly/a;

    return-void
.end method
