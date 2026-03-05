.class public final Ll1/c;
.super Lkotlin/coroutines/jvm/internal/d;
.source "SourceFile"

# interfaces
.implements Lk1/c;


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "<T:",
        "Ljava/lang/Object;",
        ">",
        "Lkotlin/coroutines/jvm/internal/d;",
        "Lk1/c<",
        "TT;>;"
    }
.end annotation


# instance fields
.field public final d:Lk1/c;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lk1/c<",
            "TT;>;"
        }
    .end annotation
.end field

.field public final e:Ls0/g;

.field public final f:I

.field private g:Ls0/g;

.field private h:Ls0/d;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ls0/d<",
            "-",
            "Lq0/q;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method public constructor <init>(Lk1/c;Ls0/g;)V
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lk1/c<",
            "-TT;>;",
            "Ls0/g;",
            ")V"
        }
    .end annotation

    sget-object v0, Ll1/b;->d:Ll1/b;

    sget-object v1, Ls0/h;->d:Ls0/h;

    invoke-direct {p0, v0, v1}, Lkotlin/coroutines/jvm/internal/d;-><init>(Ls0/d;Ls0/g;)V

    iput-object p1, p0, Ll1/c;->d:Lk1/c;

    iput-object p2, p0, Ll1/c;->e:Ls0/g;

    const/4 p1, 0x0

    invoke-static {p1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p1

    sget-object v0, Ll1/c$a;->d:Ll1/c$a;

    invoke-interface {p2, p1, v0}, Ls0/g;->fold(Ljava/lang/Object;La1/p;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/Number;

    invoke-virtual {p1}, Ljava/lang/Number;->intValue()I

    move-result p1

    iput p1, p0, Ll1/c;->f:I

    return-void
.end method

.method private final b(Ls0/g;Ls0/g;Ljava/lang/Object;)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ls0/g;",
            "Ls0/g;",
            "TT;)V"
        }
    .end annotation

    instance-of v0, p2, Ll1/a;

    if-eqz v0, :cond_0

    check-cast p2, Ll1/a;

    invoke-direct {p0, p2, p3}, Ll1/c;->e(Ll1/a;Ljava/lang/Object;)V

    :cond_0
    invoke-static {p0, p1}, Ll1/e;->a(Ll1/c;Ls0/g;)V

    iput-object p1, p0, Ll1/c;->g:Ls0/g;

    return-void
.end method

.method private final c(Ls0/d;Ljava/lang/Object;)Ljava/lang/Object;
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ls0/d<",
            "-",
            "Lq0/q;",
            ">;TT;)",
            "Ljava/lang/Object;"
        }
    .end annotation

    invoke-interface {p1}, Ls0/d;->getContext()Ls0/g;

    move-result-object v0

    invoke-static {v0}, Lh1/o1;->e(Ls0/g;)V

    iget-object v1, p0, Ll1/c;->g:Ls0/g;

    if-eq v1, v0, :cond_0

    invoke-direct {p0, v0, v1, p2}, Ll1/c;->b(Ls0/g;Ls0/g;Ljava/lang/Object;)V

    :cond_0
    iput-object p1, p0, Ll1/c;->h:Ls0/d;

    invoke-static {}, Ll1/d;->a()La1/q;

    move-result-object p1

    iget-object v0, p0, Ll1/c;->d:Lk1/c;

    invoke-interface {p1, v0, p2, p0}, La1/q;->d(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method

.method private final e(Ll1/a;Ljava/lang/Object;)V
    .locals 2

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "\n            Flow exception transparency is violated:\n                Previous \'emit\' call has thrown exception "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    iget-object p1, p1, Ll1/a;->d:Ljava/lang/Throwable;

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    const-string p1, ", but then emission attempt of value \'"

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    const-string p1, "\' has been detected.\n                Emissions from \'catch\' blocks are prohibited in order to avoid unspecified behaviour, \'Flow.catch\' operator can be used instead.\n                For a more detailed explanation, please refer to Flow documentation.\n            "

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-static {p1}, Lg1/d;->e(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p1

    new-instance p2, Ljava/lang/IllegalStateException;

    invoke-virtual {p1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object p1

    invoke-direct {p2, p1}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw p2
.end method


# virtual methods
.method public emit(Ljava/lang/Object;Ls0/d;)Ljava/lang/Object;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;",
            "Ls0/d<",
            "-",
            "Lq0/q;",
            ">;)",
            "Ljava/lang/Object;"
        }
    .end annotation

    :try_start_0
    invoke-direct {p0, p2, p1}, Ll1/c;->c(Ls0/d;Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    invoke-static {}, Lt0/b;->c()Ljava/lang/Object;

    move-result-object v0

    if-ne p1, v0, :cond_0

    invoke-static {p2}, Lkotlin/coroutines/jvm/internal/h;->c(Ls0/d;)V

    :cond_0
    invoke-static {}, Lt0/b;->c()Ljava/lang/Object;

    move-result-object p2

    if-ne p1, p2, :cond_1

    return-object p1

    :cond_1
    sget-object p1, Lq0/q;->a:Lq0/q;

    return-object p1

    :catchall_0
    move-exception p1

    new-instance p2, Ll1/a;

    invoke-direct {p2, p1}, Ll1/a;-><init>(Ljava/lang/Throwable;)V

    iput-object p2, p0, Ll1/c;->g:Ls0/g;

    throw p1
.end method

.method public getCallerFrame()Lkotlin/coroutines/jvm/internal/e;
    .locals 2

    iget-object v0, p0, Ll1/c;->h:Ls0/d;

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

    iget-object v0, p0, Ll1/c;->h:Ls0/d;

    if-nez v0, :cond_0

    const/4 v0, 0x0

    goto :goto_0

    :cond_0
    invoke-interface {v0}, Ls0/d;->getContext()Ls0/g;

    move-result-object v0

    :goto_0
    if-nez v0, :cond_1

    sget-object v0, Ls0/h;->d:Ls0/h;

    :cond_1
    return-object v0
.end method

.method public getStackTraceElement()Ljava/lang/StackTraceElement;
    .locals 1

    const/4 v0, 0x0

    return-object v0
.end method

.method public invokeSuspend(Ljava/lang/Object;)Ljava/lang/Object;
    .locals 2

    invoke-static {p1}, Lq0/k;->b(Ljava/lang/Object;)Ljava/lang/Throwable;

    move-result-object v0

    if-eqz v0, :cond_0

    new-instance v1, Ll1/a;

    invoke-direct {v1, v0}, Ll1/a;-><init>(Ljava/lang/Throwable;)V

    iput-object v1, p0, Ll1/c;->g:Ls0/g;

    :cond_0
    iget-object v0, p0, Ll1/c;->h:Ls0/d;

    if-nez v0, :cond_1

    goto :goto_0

    :cond_1
    invoke-interface {v0, p1}, Ls0/d;->resumeWith(Ljava/lang/Object;)V

    :goto_0
    invoke-static {}, Lt0/b;->c()Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method

.method public releaseIntercepted()V
    .locals 0

    invoke-super {p0}, Lkotlin/coroutines/jvm/internal/d;->releaseIntercepted()V

    return-void
.end method
