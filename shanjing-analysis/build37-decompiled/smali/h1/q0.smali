.class public final Lh1/q0;
.super Ljava/lang/Object;
.source "SourceFile"


# direct methods
.method public static final a(Lh1/p0;I)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<T:",
            "Ljava/lang/Object;",
            ">(",
            "Lh1/p0<",
            "-TT;>;I)V"
        }
    .end annotation

    invoke-virtual {p0}, Lh1/p0;->c()Ls0/d;

    move-result-object v0

    const/4 v1, 0x4

    if-ne p1, v1, :cond_0

    const/4 v1, 0x1

    goto :goto_0

    :cond_0
    const/4 v1, 0x0

    :goto_0
    if-nez v1, :cond_2

    instance-of v2, v0, Lkotlinx/coroutines/internal/f;

    if-eqz v2, :cond_2

    invoke-static {p1}, Lh1/q0;->b(I)Z

    move-result p1

    iget v2, p0, Lh1/p0;->f:I

    invoke-static {v2}, Lh1/q0;->b(I)Z

    move-result v2

    if-ne p1, v2, :cond_2

    move-object p1, v0

    check-cast p1, Lkotlinx/coroutines/internal/f;

    iget-object p1, p1, Lkotlinx/coroutines/internal/f;->g:Lh1/f0;

    invoke-interface {v0}, Ls0/d;->getContext()Ls0/g;

    move-result-object v0

    invoke-virtual {p1, v0}, Lh1/f0;->j(Ls0/g;)Z

    move-result v1

    if-eqz v1, :cond_1

    invoke-virtual {p1, v0, p0}, Lh1/f0;->g(Ls0/g;Ljava/lang/Runnable;)V

    goto :goto_1

    :cond_1
    invoke-static {p0}, Lh1/q0;->e(Lh1/p0;)V

    goto :goto_1

    :cond_2
    invoke-static {p0, v0, v1}, Lh1/q0;->d(Lh1/p0;Ls0/d;Z)V

    :goto_1
    return-void
.end method

.method public static final b(I)Z
    .locals 2

    const/4 v0, 0x1

    if-eq p0, v0, :cond_1

    const/4 v1, 0x2

    if-ne p0, v1, :cond_0

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :cond_1
    :goto_0
    return v0
.end method

.method public static final c(I)Z
    .locals 1

    const/4 v0, 0x2

    if-ne p0, v0, :cond_0

    const/4 p0, 0x1

    goto :goto_0

    :cond_0
    const/4 p0, 0x0

    :goto_0
    return p0
.end method

.method public static final d(Lh1/p0;Ls0/d;Z)V
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<T:",
            "Ljava/lang/Object;",
            ">(",
            "Lh1/p0<",
            "-TT;>;",
            "Ls0/d<",
            "-TT;>;Z)V"
        }
    .end annotation

    invoke-virtual {p0}, Lh1/p0;->h()Ljava/lang/Object;

    move-result-object v0

    invoke-virtual {p0, v0}, Lh1/p0;->d(Ljava/lang/Object;)Ljava/lang/Throwable;

    move-result-object v1

    if-eqz v1, :cond_0

    sget-object p0, Lq0/k;->d:Lq0/k$a;

    invoke-static {v1}, Lq0/l;->a(Ljava/lang/Throwable;)Ljava/lang/Object;

    move-result-object p0

    goto :goto_0

    :cond_0
    sget-object v1, Lq0/k;->d:Lq0/k$a;

    invoke-virtual {p0, v0}, Lh1/p0;->e(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    :goto_0
    invoke-static {p0}, Lq0/k;->a(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p0

    if-eqz p2, :cond_5

    check-cast p1, Lkotlinx/coroutines/internal/f;

    iget-object p2, p1, Lkotlinx/coroutines/internal/f;->h:Ls0/d;

    iget-object v0, p1, Lkotlinx/coroutines/internal/f;->j:Ljava/lang/Object;

    invoke-interface {p2}, Ls0/d;->getContext()Ls0/g;

    move-result-object v1

    invoke-static {v1, v0}, Lkotlinx/coroutines/internal/b0;->c(Ls0/g;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    sget-object v2, Lkotlinx/coroutines/internal/b0;->a:Lkotlinx/coroutines/internal/x;

    if-eq v0, v2, :cond_1

    invoke-static {p2, v1, v0}, Lh1/e0;->e(Ls0/d;Ls0/g;Ljava/lang/Object;)Lh1/d2;

    move-result-object p2

    goto :goto_1

    :cond_1
    const/4 p2, 0x0

    :goto_1
    :try_start_0
    iget-object p1, p1, Lkotlinx/coroutines/internal/f;->h:Ls0/d;

    invoke-interface {p1, p0}, Ls0/d;->resumeWith(Ljava/lang/Object;)V

    sget-object p0, Lq0/q;->a:Lq0/q;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-eqz p2, :cond_2

    invoke-virtual {p2}, Lh1/d2;->x0()Z

    move-result p0

    if-eqz p0, :cond_6

    :cond_2
    invoke-static {v1, v0}, Lkotlinx/coroutines/internal/b0;->a(Ls0/g;Ljava/lang/Object;)V

    goto :goto_2

    :catchall_0
    move-exception p0

    if-eqz p2, :cond_3

    invoke-virtual {p2}, Lh1/d2;->x0()Z

    move-result p1

    if-eqz p1, :cond_4

    :cond_3
    invoke-static {v1, v0}, Lkotlinx/coroutines/internal/b0;->a(Ls0/g;Ljava/lang/Object;)V

    :cond_4
    throw p0

    :cond_5
    invoke-interface {p1, p0}, Ls0/d;->resumeWith(Ljava/lang/Object;)V

    :cond_6
    :goto_2
    return-void
.end method

.method private static final e(Lh1/p0;)V
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lh1/p0<",
            "*>;)V"
        }
    .end annotation

    sget-object v0, Lh1/b2;->a:Lh1/b2;

    invoke-virtual {v0}, Lh1/b2;->a()Lh1/v0;

    move-result-object v0

    invoke-virtual {v0}, Lh1/v0;->v()Z

    move-result v1

    if-eqz v1, :cond_0

    invoke-virtual {v0, p0}, Lh1/v0;->r(Lh1/p0;)V

    goto :goto_1

    :cond_0
    const/4 v1, 0x1

    invoke-virtual {v0, v1}, Lh1/v0;->t(Z)V

    :try_start_0
    invoke-virtual {p0}, Lh1/p0;->c()Ls0/d;

    move-result-object v2

    invoke-static {p0, v2, v1}, Lh1/q0;->d(Lh1/p0;Ls0/d;Z)V

    :cond_1
    invoke-virtual {v0}, Lh1/v0;->x()Z

    move-result v2
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    if-nez v2, :cond_1

    goto :goto_0

    :catchall_0
    move-exception v2

    const/4 v3, 0x0

    :try_start_1
    invoke-virtual {p0, v2, v3}, Lh1/p0;->f(Ljava/lang/Throwable;Ljava/lang/Throwable;)V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    :goto_0
    invoke-virtual {v0, v1}, Lh1/v0;->o(Z)V

    :goto_1
    return-void

    :catchall_1
    move-exception p0

    invoke-virtual {v0, v1}, Lh1/v0;->o(Z)V

    throw p0
.end method
