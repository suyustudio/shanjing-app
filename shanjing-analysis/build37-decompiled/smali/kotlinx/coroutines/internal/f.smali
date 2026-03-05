.class public final Lkotlinx/coroutines/internal/f;
.super Lh1/p0;
.source "SourceFile"

# interfaces
.implements Lkotlin/coroutines/jvm/internal/e;
.implements Ls0/d;


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "<T:",
        "Ljava/lang/Object;",
        ">",
        "Lh1/p0<",
        "TT;>;",
        "Lkotlin/coroutines/jvm/internal/e;",
        "Ls0/d<",
        "TT;>;"
    }
.end annotation


# static fields
.field private static final synthetic k:Ljava/util/concurrent/atomic/AtomicReferenceFieldUpdater;


# instance fields
.field private volatile synthetic _reusableCancellableContinuation:Ljava/lang/Object;

.field public final g:Lh1/f0;

.field public final h:Ls0/d;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ls0/d<",
            "TT;>;"
        }
    .end annotation
.end field

.field public i:Ljava/lang/Object;

.field public final j:Ljava/lang/Object;


# direct methods
.method static constructor <clinit>()V
    .locals 3

    const-class v0, Lkotlinx/coroutines/internal/f;

    const-class v1, Ljava/lang/Object;

    const-string v2, "_reusableCancellableContinuation"

    invoke-static {v0, v1, v2}, Ljava/util/concurrent/atomic/AtomicReferenceFieldUpdater;->newUpdater(Ljava/lang/Class;Ljava/lang/Class;Ljava/lang/String;)Ljava/util/concurrent/atomic/AtomicReferenceFieldUpdater;

    move-result-object v0

    sput-object v0, Lkotlinx/coroutines/internal/f;->k:Ljava/util/concurrent/atomic/AtomicReferenceFieldUpdater;

    return-void
.end method

.method public constructor <init>(Lh1/f0;Ls0/d;)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lh1/f0;",
            "Ls0/d<",
            "-TT;>;)V"
        }
    .end annotation

    const/4 v0, -0x1

    invoke-direct {p0, v0}, Lh1/p0;-><init>(I)V

    iput-object p1, p0, Lkotlinx/coroutines/internal/f;->g:Lh1/f0;

    iput-object p2, p0, Lkotlinx/coroutines/internal/f;->h:Ls0/d;

    invoke-static {}, Lkotlinx/coroutines/internal/g;->a()Lkotlinx/coroutines/internal/x;

    move-result-object p1

    iput-object p1, p0, Lkotlinx/coroutines/internal/f;->i:Ljava/lang/Object;

    invoke-virtual {p0}, Lkotlinx/coroutines/internal/f;->getContext()Ls0/g;

    move-result-object p1

    invoke-static {p1}, Lkotlinx/coroutines/internal/b0;->b(Ls0/g;)Ljava/lang/Object;

    move-result-object p1

    iput-object p1, p0, Lkotlinx/coroutines/internal/f;->j:Ljava/lang/Object;

    const/4 p1, 0x0

    iput-object p1, p0, Lkotlinx/coroutines/internal/f;->_reusableCancellableContinuation:Ljava/lang/Object;

    return-void
.end method

.method private final l()Lh1/m;
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Lh1/m<",
            "*>;"
        }
    .end annotation

    iget-object v0, p0, Lkotlinx/coroutines/internal/f;->_reusableCancellableContinuation:Ljava/lang/Object;

    instance-of v1, v0, Lh1/m;

    if-eqz v1, :cond_0

    check-cast v0, Lh1/m;

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return-object v0
.end method


# virtual methods
.method public b(Ljava/lang/Object;Ljava/lang/Throwable;)V
    .locals 1

    instance-of v0, p1, Lh1/a0;

    if-eqz v0, :cond_0

    check-cast p1, Lh1/a0;

    iget-object p1, p1, Lh1/a0;->b:La1/l;

    invoke-interface {p1, p2}, La1/l;->invoke(Ljava/lang/Object;)Ljava/lang/Object;

    :cond_0
    return-void
.end method

.method public c()Ls0/d;
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ls0/d<",
            "TT;>;"
        }
    .end annotation

    return-object p0
.end method

.method public getCallerFrame()Lkotlin/coroutines/jvm/internal/e;
    .locals 2

    iget-object v0, p0, Lkotlinx/coroutines/internal/f;->h:Ls0/d;

    instance-of v1, v0, Lkotlin/coroutines/jvm/internal/e;

    if-eqz v1, :cond_0

    check-cast v0, Lkotlin/coroutines/jvm/internal/e;

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return-object v0
.end method

.method public getContext()Ls0/g;
    .locals 1

    iget-object v0, p0, Lkotlinx/coroutines/internal/f;->h:Ls0/d;

    invoke-interface {v0}, Ls0/d;->getContext()Ls0/g;

    move-result-object v0

    return-object v0
.end method

.method public h()Ljava/lang/Object;
    .locals 2

    iget-object v0, p0, Lkotlinx/coroutines/internal/f;->i:Ljava/lang/Object;

    invoke-static {}, Lkotlinx/coroutines/internal/g;->a()Lkotlinx/coroutines/internal/x;

    move-result-object v1

    iput-object v1, p0, Lkotlinx/coroutines/internal/f;->i:Ljava/lang/Object;

    return-object v0
.end method

.method public final i()V
    .locals 2

    :cond_0
    iget-object v0, p0, Lkotlinx/coroutines/internal/f;->_reusableCancellableContinuation:Ljava/lang/Object;

    sget-object v1, Lkotlinx/coroutines/internal/g;->b:Lkotlinx/coroutines/internal/x;

    if-eq v0, v1, :cond_0

    return-void
.end method

.method public final k()Lh1/m;
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Lh1/m<",
            "TT;>;"
        }
    .end annotation

    :cond_0
    :goto_0
    iget-object v0, p0, Lkotlinx/coroutines/internal/f;->_reusableCancellableContinuation:Ljava/lang/Object;

    if-nez v0, :cond_1

    sget-object v0, Lkotlinx/coroutines/internal/g;->b:Lkotlinx/coroutines/internal/x;

    iput-object v0, p0, Lkotlinx/coroutines/internal/f;->_reusableCancellableContinuation:Ljava/lang/Object;

    const/4 v0, 0x0

    return-object v0

    :cond_1
    instance-of v1, v0, Lh1/m;

    if-eqz v1, :cond_2

    sget-object v1, Lkotlinx/coroutines/internal/f;->k:Ljava/util/concurrent/atomic/AtomicReferenceFieldUpdater;

    sget-object v2, Lkotlinx/coroutines/internal/g;->b:Lkotlinx/coroutines/internal/x;

    invoke-static {v1, p0, v0, v2}, Lh1/l;->a(Ljava/util/concurrent/atomic/AtomicReferenceFieldUpdater;Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    check-cast v0, Lh1/m;

    return-object v0

    :cond_2
    sget-object v1, Lkotlinx/coroutines/internal/g;->b:Lkotlinx/coroutines/internal/x;

    if-ne v0, v1, :cond_3

    goto :goto_0

    :cond_3
    instance-of v1, v0, Ljava/lang/Throwable;

    if-eqz v1, :cond_4

    goto :goto_0

    :cond_4
    const-string v1, "Inconsistent state "

    invoke-static {v1, v0}, Lkotlin/jvm/internal/i;->j(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    new-instance v1, Ljava/lang/IllegalStateException;

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-direct {v1, v0}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method public final m()Z
    .locals 1

    iget-object v0, p0, Lkotlinx/coroutines/internal/f;->_reusableCancellableContinuation:Ljava/lang/Object;

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    goto :goto_0

    :cond_0
    const/4 v0, 0x0

    :goto_0
    return v0
.end method

.method public final n(Ljava/lang/Throwable;)Z
    .locals 4

    :cond_0
    iget-object v0, p0, Lkotlinx/coroutines/internal/f;->_reusableCancellableContinuation:Ljava/lang/Object;

    sget-object v1, Lkotlinx/coroutines/internal/g;->b:Lkotlinx/coroutines/internal/x;

    invoke-static {v0, v1}, Lkotlin/jvm/internal/i;->a(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v2

    const/4 v3, 0x1

    if-eqz v2, :cond_1

    sget-object v0, Lkotlinx/coroutines/internal/f;->k:Ljava/util/concurrent/atomic/AtomicReferenceFieldUpdater;

    invoke-static {v0, p0, v1, p1}, Lh1/l;->a(Ljava/util/concurrent/atomic/AtomicReferenceFieldUpdater;Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    return v3

    :cond_1
    instance-of v1, v0, Ljava/lang/Throwable;

    if-eqz v1, :cond_2

    return v3

    :cond_2
    sget-object v1, Lkotlinx/coroutines/internal/f;->k:Ljava/util/concurrent/atomic/AtomicReferenceFieldUpdater;

    const/4 v2, 0x0

    invoke-static {v1, p0, v0, v2}, Lh1/l;->a(Ljava/util/concurrent/atomic/AtomicReferenceFieldUpdater;Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    const/4 p1, 0x0

    return p1
.end method

.method public final q()V
    .locals 1

    invoke-virtual {p0}, Lkotlinx/coroutines/internal/f;->i()V

    invoke-direct {p0}, Lkotlinx/coroutines/internal/f;->l()Lh1/m;

    move-result-object v0

    if-nez v0, :cond_0

    goto :goto_0

    :cond_0
    invoke-virtual {v0}, Lh1/m;->s()V

    :goto_0
    return-void
.end method

.method public resumeWith(Ljava/lang/Object;)V
    .locals 6

    iget-object v0, p0, Lkotlinx/coroutines/internal/f;->h:Ls0/d;

    invoke-interface {v0}, Ls0/d;->getContext()Ls0/g;

    move-result-object v0

    const/4 v1, 0x0

    const/4 v2, 0x1

    invoke-static {p1, v1, v2, v1}, Lh1/d0;->d(Ljava/lang/Object;La1/l;ILjava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    iget-object v4, p0, Lkotlinx/coroutines/internal/f;->g:Lh1/f0;

    invoke-virtual {v4, v0}, Lh1/f0;->j(Ls0/g;)Z

    move-result v4

    const/4 v5, 0x0

    if-eqz v4, :cond_0

    iput-object v3, p0, Lkotlinx/coroutines/internal/f;->i:Ljava/lang/Object;

    iput v5, p0, Lh1/p0;->f:I

    iget-object p1, p0, Lkotlinx/coroutines/internal/f;->g:Lh1/f0;

    invoke-virtual {p1, v0, p0}, Lh1/f0;->g(Ls0/g;Ljava/lang/Runnable;)V

    goto :goto_1

    :cond_0
    sget-object v0, Lh1/b2;->a:Lh1/b2;

    invoke-virtual {v0}, Lh1/b2;->a()Lh1/v0;

    move-result-object v0

    invoke-virtual {v0}, Lh1/v0;->v()Z

    move-result v4

    if-eqz v4, :cond_1

    iput-object v3, p0, Lkotlinx/coroutines/internal/f;->i:Ljava/lang/Object;

    iput v5, p0, Lh1/p0;->f:I

    invoke-virtual {v0, p0}, Lh1/v0;->r(Lh1/p0;)V

    goto :goto_1

    :cond_1
    invoke-virtual {v0, v2}, Lh1/v0;->t(Z)V

    :try_start_0
    invoke-virtual {p0}, Lkotlinx/coroutines/internal/f;->getContext()Ls0/g;

    move-result-object v3

    iget-object v4, p0, Lkotlinx/coroutines/internal/f;->j:Ljava/lang/Object;

    invoke-static {v3, v4}, Lkotlinx/coroutines/internal/b0;->c(Ls0/g;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_1

    :try_start_1
    iget-object v5, p0, Lkotlinx/coroutines/internal/f;->h:Ls0/d;

    invoke-interface {v5, p1}, Ls0/d;->resumeWith(Ljava/lang/Object;)V

    sget-object p1, Lq0/q;->a:Lq0/q;
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    :try_start_2
    invoke-static {v3, v4}, Lkotlinx/coroutines/internal/b0;->a(Ls0/g;Ljava/lang/Object;)V

    :cond_2
    invoke-virtual {v0}, Lh1/v0;->x()Z

    move-result p1

    if-nez p1, :cond_2

    goto :goto_0

    :catchall_0
    move-exception p1

    invoke-static {v3, v4}, Lkotlinx/coroutines/internal/b0;->a(Ls0/g;Ljava/lang/Object;)V

    throw p1
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_1

    :catchall_1
    move-exception p1

    :try_start_3
    invoke-virtual {p0, p1, v1}, Lh1/p0;->f(Ljava/lang/Throwable;Ljava/lang/Throwable;)V
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_2

    :goto_0
    invoke-virtual {v0, v2}, Lh1/v0;->o(Z)V

    :goto_1
    return-void

    :catchall_2
    move-exception p1

    invoke-virtual {v0, v2}, Lh1/v0;->o(Z)V

    throw p1
.end method

.method public final s(Lh1/k;)Ljava/lang/Throwable;
    .locals 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lh1/k<",
            "*>;)",
            "Ljava/lang/Throwable;"
        }
    .end annotation

    :cond_0
    iget-object v0, p0, Lkotlinx/coroutines/internal/f;->_reusableCancellableContinuation:Ljava/lang/Object;

    sget-object v1, Lkotlinx/coroutines/internal/g;->b:Lkotlinx/coroutines/internal/x;

    const/4 v2, 0x0

    if-ne v0, v1, :cond_1

    sget-object v0, Lkotlinx/coroutines/internal/f;->k:Ljava/util/concurrent/atomic/AtomicReferenceFieldUpdater;

    invoke-static {v0, p0, v1, p1}, Lh1/l;->a(Ljava/util/concurrent/atomic/AtomicReferenceFieldUpdater;Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    return-object v2

    :cond_1
    instance-of p1, v0, Ljava/lang/Throwable;

    if-eqz p1, :cond_3

    sget-object p1, Lkotlinx/coroutines/internal/f;->k:Ljava/util/concurrent/atomic/AtomicReferenceFieldUpdater;

    invoke-static {p1, p0, v0, v2}, Lh1/l;->a(Ljava/util/concurrent/atomic/AtomicReferenceFieldUpdater;Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p1

    if-eqz p1, :cond_2

    check-cast v0, Ljava/lang/Throwable;

    return-object v0

    :cond_2
    new-instance p1, Ljava/lang/IllegalArgumentException;

    const-string v0, "Failed requirement."

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-direct {p1, v0}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw p1

    :cond_3
    const-string p1, "Inconsistent state "

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->j(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;

    move-result-object p1

    new-instance v0, Ljava/lang/IllegalStateException;

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {v0, p1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method public toString()Ljava/lang/String;
    .locals 2

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "DispatchedContinuation["

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lkotlinx/coroutines/internal/f;->g:Lh1/f0;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    const-string v1, ", "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object v1, p0, Lkotlinx/coroutines/internal/f;->h:Ls0/d;

    invoke-static {v1}, Lh1/m0;->c(Ls0/d;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const/16 v1, 0x5d

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
