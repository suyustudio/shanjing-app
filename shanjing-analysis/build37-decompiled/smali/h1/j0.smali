.class public final Lh1/j0;
.super Ljava/lang/Object;
.source "SourceFile"


# direct methods
.method public static final a(Ls0/g;)Lh1/i0;
    .locals 3

    new-instance v0, Lkotlinx/coroutines/internal/e;

    sget-object v1, Lh1/k1;->a:Lh1/k1$b;

    invoke-interface {p0, v1}, Ls0/g;->get(Ls0/g$c;)Ls0/g$b;

    move-result-object v1

    if-eqz v1, :cond_0

    goto :goto_0

    :cond_0
    const/4 v1, 0x1

    const/4 v2, 0x0

    invoke-static {v2, v1, v2}, Lh1/o1;->b(Lh1/k1;ILjava/lang/Object;)Lh1/x;

    move-result-object v1

    invoke-interface {p0, v1}, Ls0/g;->plus(Ls0/g;)Ls0/g;

    move-result-object p0

    :goto_0
    invoke-direct {v0, p0}, Lkotlinx/coroutines/internal/e;-><init>(Ls0/g;)V

    return-object v0
.end method
