.class final Lj1/a$a;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lj1/g;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lj1/a;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1a
    name = "a"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "<E:",
        "Ljava/lang/Object;",
        ">",
        "Ljava/lang/Object;",
        "Lj1/g<",
        "TE;>;"
    }
.end annotation


# instance fields
.field public final a:Lj1/a;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lj1/a<",
            "TE;>;"
        }
    .end annotation
.end field

.field private b:Ljava/lang/Object;


# direct methods
.method public constructor <init>(Lj1/a;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lj1/a<",
            "TE;>;)V"
        }
    .end annotation

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lj1/a$a;->a:Lj1/a;

    sget-object p1, Lj1/b;->d:Lkotlinx/coroutines/internal/x;

    iput-object p1, p0, Lj1/a$a;->b:Ljava/lang/Object;

    return-void
.end method

.method private final c(Ljava/lang/Object;)Z
    .locals 1

    instance-of v0, p1, Lj1/j;

    if-eqz v0, :cond_1

    check-cast p1, Lj1/j;

    iget-object v0, p1, Lj1/j;->g:Ljava/lang/Throwable;

    if-nez v0, :cond_0

    const/4 p1, 0x0

    return p1

    :cond_0
    invoke-virtual {p1}, Lj1/j;->E()Ljava/lang/Throwable;

    move-result-object p1

    invoke-static {p1}, Lkotlinx/coroutines/internal/w;->a(Ljava/lang/Throwable;)Ljava/lang/Throwable;

    move-result-object p1

    throw p1

    :cond_1
    const/4 p1, 0x1

    return p1
.end method

.method private final d(Ls0/d;)Ljava/lang/Object;
    .locals 5
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ls0/d<",
            "-",
            "Ljava/lang/Boolean;",
            ">;)",
            "Ljava/lang/Object;"
        }
    .end annotation

    invoke-static {p1}, Lt0/b;->b(Ls0/d;)Ls0/d;

    move-result-object v0

    invoke-static {v0}, Lh1/o;->a(Ls0/d;)Lh1/m;

    move-result-object v0

    new-instance v1, Lj1/a$b;

    invoke-direct {v1, p0, v0}, Lj1/a$b;-><init>(Lj1/a$a;Lh1/k;)V

    :cond_0
    iget-object v2, p0, Lj1/a$a;->a:Lj1/a;

    invoke-static {v2, v1}, Lj1/a;->n(Lj1/a;Lj1/o;)Z

    move-result v2

    if-eqz v2, :cond_1

    iget-object v2, p0, Lj1/a$a;->a:Lj1/a;

    invoke-static {v2, v0, v1}, Lj1/a;->o(Lj1/a;Lh1/k;Lj1/o;)V

    goto :goto_2

    :cond_1
    iget-object v2, p0, Lj1/a$a;->a:Lj1/a;

    invoke-virtual {v2}, Lj1/a;->v()Ljava/lang/Object;

    move-result-object v2

    invoke-virtual {p0, v2}, Lj1/a$a;->e(Ljava/lang/Object;)V

    instance-of v3, v2, Lj1/j;

    if-eqz v3, :cond_3

    check-cast v2, Lj1/j;

    iget-object v1, v2, Lj1/j;->g:Ljava/lang/Throwable;

    if-nez v1, :cond_2

    const/4 v1, 0x0

    invoke-static {v1}, Lkotlin/coroutines/jvm/internal/b;->a(Z)Ljava/lang/Boolean;

    move-result-object v1

    goto :goto_0

    :cond_2
    invoke-virtual {v2}, Lj1/j;->E()Ljava/lang/Throwable;

    move-result-object v1

    sget-object v2, Lq0/k;->d:Lq0/k$a;

    invoke-static {v1}, Lq0/l;->a(Ljava/lang/Throwable;)Ljava/lang/Object;

    move-result-object v1

    :goto_0
    invoke-static {v1}, Lq0/k;->a(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1

    invoke-interface {v0, v1}, Ls0/d;->resumeWith(Ljava/lang/Object;)V

    goto :goto_2

    :cond_3
    sget-object v3, Lj1/b;->d:Lkotlinx/coroutines/internal/x;

    if-eq v2, v3, :cond_0

    const/4 v1, 0x1

    invoke-static {v1}, Lkotlin/coroutines/jvm/internal/b;->a(Z)Ljava/lang/Boolean;

    move-result-object v1

    iget-object v3, p0, Lj1/a$a;->a:Lj1/a;

    iget-object v3, v3, Lj1/c;->b:La1/l;

    if-nez v3, :cond_4

    const/4 v2, 0x0

    goto :goto_1

    :cond_4
    invoke-interface {v0}, Ls0/d;->getContext()Ls0/g;

    move-result-object v4

    invoke-static {v3, v2, v4}, Lkotlinx/coroutines/internal/s;->a(La1/l;Ljava/lang/Object;Ls0/g;)La1/l;

    move-result-object v2

    :goto_1
    invoke-interface {v0, v1, v2}, Lh1/k;->g(Ljava/lang/Object;La1/l;)V

    :goto_2
    invoke-virtual {v0}, Lh1/m;->w()Ljava/lang/Object;

    move-result-object v0

    invoke-static {}, Lt0/b;->c()Ljava/lang/Object;

    move-result-object v1

    if-ne v0, v1, :cond_5

    invoke-static {p1}, Lkotlin/coroutines/jvm/internal/h;->c(Ls0/d;)V

    :cond_5
    return-object v0
.end method


# virtual methods
.method public a(Ls0/d;)Ljava/lang/Object;
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ls0/d<",
            "-",
            "Ljava/lang/Boolean;",
            ">;)",
            "Ljava/lang/Object;"
        }
    .end annotation

    invoke-virtual {p0}, Lj1/a$a;->b()Ljava/lang/Object;

    move-result-object v0

    sget-object v1, Lj1/b;->d:Lkotlinx/coroutines/internal/x;

    if-eq v0, v1, :cond_0

    :goto_0
    invoke-virtual {p0}, Lj1/a$a;->b()Ljava/lang/Object;

    move-result-object p1

    invoke-direct {p0, p1}, Lj1/a$a;->c(Ljava/lang/Object;)Z

    move-result p1

    invoke-static {p1}, Lkotlin/coroutines/jvm/internal/b;->a(Z)Ljava/lang/Boolean;

    move-result-object p1

    return-object p1

    :cond_0
    iget-object v0, p0, Lj1/a$a;->a:Lj1/a;

    invoke-virtual {v0}, Lj1/a;->v()Ljava/lang/Object;

    move-result-object v0

    invoke-virtual {p0, v0}, Lj1/a$a;->e(Ljava/lang/Object;)V

    invoke-virtual {p0}, Lj1/a$a;->b()Ljava/lang/Object;

    move-result-object v0

    if-eq v0, v1, :cond_1

    goto :goto_0

    :cond_1
    invoke-direct {p0, p1}, Lj1/a$a;->d(Ls0/d;)Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method

.method public final b()Ljava/lang/Object;
    .locals 1

    iget-object v0, p0, Lj1/a$a;->b:Ljava/lang/Object;

    return-object v0
.end method

.method public final e(Ljava/lang/Object;)V
    .locals 0

    iput-object p1, p0, Lj1/a$a;->b:Ljava/lang/Object;

    return-void
.end method

.method public next()Ljava/lang/Object;
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()TE;"
        }
    .end annotation

    iget-object v0, p0, Lj1/a$a;->b:Ljava/lang/Object;

    instance-of v1, v0, Lj1/j;

    if-nez v1, :cond_1

    sget-object v1, Lj1/b;->d:Lkotlinx/coroutines/internal/x;

    if-eq v0, v1, :cond_0

    iput-object v1, p0, Lj1/a$a;->b:Ljava/lang/Object;

    return-object v0

    :cond_0
    new-instance v0, Ljava/lang/IllegalStateException;

    const-string v1, "\'hasNext\' should be called prior to \'next\' invocation"

    invoke-direct {v0, v1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0

    :cond_1
    check-cast v0, Lj1/j;

    invoke-virtual {v0}, Lj1/j;->E()Ljava/lang/Throwable;

    move-result-object v0

    invoke-static {v0}, Lkotlinx/coroutines/internal/w;->a(Ljava/lang/Throwable;)Ljava/lang/Throwable;

    move-result-object v0

    throw v0
.end method
