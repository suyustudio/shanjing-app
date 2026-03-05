.class public final Lm1/a;
.super Ljava/lang/Object;
.source "SourceFile"


# direct methods
.method public static final synthetic a(Ls0/d;Ljava/lang/Throwable;)V
    .locals 0

    invoke-static {p0, p1}, Lm1/a;->b(Ls0/d;Ljava/lang/Throwable;)V

    return-void
.end method

.method private static final b(Ls0/d;Ljava/lang/Throwable;)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ls0/d<",
            "*>;",
            "Ljava/lang/Throwable;",
            ")V"
        }
    .end annotation

    sget-object v0, Lq0/k;->d:Lq0/k$a;

    invoke-static {p1}, Lq0/l;->a(Ljava/lang/Throwable;)Ljava/lang/Object;

    move-result-object v0

    invoke-static {v0}, Lq0/k;->a(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    invoke-interface {p0, v0}, Ls0/d;->resumeWith(Ljava/lang/Object;)V

    throw p1
.end method

.method public static final c(La1/p;Ljava/lang/Object;Ls0/d;La1/l;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<R:",
            "Ljava/lang/Object;",
            "T:",
            "Ljava/lang/Object;",
            ">(",
            "La1/p<",
            "-TR;-",
            "Ls0/d<",
            "-TT;>;+",
            "Ljava/lang/Object;",
            ">;TR;",
            "Ls0/d<",
            "-TT;>;",
            "La1/l<",
            "-",
            "Ljava/lang/Throwable;",
            "Lq0/q;",
            ">;)V"
        }
    .end annotation

    :try_start_0
    invoke-static {p0, p1, p2}, Lt0/b;->a(La1/p;Ljava/lang/Object;Ls0/d;)Ls0/d;

    move-result-object p0

    invoke-static {p0}, Lt0/b;->b(Ls0/d;)Ls0/d;

    move-result-object p0

    sget-object p1, Lq0/k;->d:Lq0/k$a;

    sget-object p1, Lq0/q;->a:Lq0/q;

    invoke-static {p1}, Lq0/k;->a(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    invoke-static {p0, p1, p3}, Lkotlinx/coroutines/internal/g;->b(Ls0/d;Ljava/lang/Object;La1/l;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    move-exception p0

    invoke-static {p2, p0}, Lm1/a;->a(Ls0/d;Ljava/lang/Throwable;)V

    :goto_0
    return-void
.end method

.method public static final d(Ls0/d;Ls0/d;)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ls0/d<",
            "-",
            "Lq0/q;",
            ">;",
            "Ls0/d<",
            "*>;)V"
        }
    .end annotation

    :try_start_0
    invoke-static {p0}, Lt0/b;->b(Ls0/d;)Ls0/d;

    move-result-object p0

    sget-object v0, Lq0/k;->d:Lq0/k$a;

    sget-object v0, Lq0/q;->a:Lq0/q;

    invoke-static {v0}, Lq0/k;->a(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    const/4 v1, 0x2

    const/4 v2, 0x0

    invoke-static {p0, v0, v2, v1, v2}, Lkotlinx/coroutines/internal/g;->c(Ls0/d;Ljava/lang/Object;La1/l;ILjava/lang/Object;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    :catchall_0
    move-exception p0

    invoke-static {p1, p0}, Lm1/a;->a(Ls0/d;Ljava/lang/Throwable;)V

    :goto_0
    return-void
.end method

.method public static synthetic e(La1/p;Ljava/lang/Object;Ls0/d;La1/l;ILjava/lang/Object;)V
    .locals 0

    and-int/lit8 p4, p4, 0x4

    if-eqz p4, :cond_0

    const/4 p3, 0x0

    :cond_0
    invoke-static {p0, p1, p2, p3}, Lm1/a;->c(La1/p;Ljava/lang/Object;Ls0/d;La1/l;)V

    return-void
.end method
