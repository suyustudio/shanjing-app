.class public final Ls0/f;
.super Ljava/lang/Object;
.source "SourceFile"


# direct methods
.method public static final a(La1/p;Ljava/lang/Object;Ls0/d;)V
    .locals 1
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
            "-TT;>;)V"
        }
    .end annotation

    const-string v0, "<this>"

    invoke-static {p0, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "completion"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-static {p0, p1, p2}, Lt0/b;->a(La1/p;Ljava/lang/Object;Ls0/d;)Ls0/d;

    move-result-object p0

    invoke-static {p0}, Lt0/b;->b(Ls0/d;)Ls0/d;

    move-result-object p0

    sget-object p1, Lq0/k;->d:Lq0/k$a;

    sget-object p1, Lq0/q;->a:Lq0/q;

    invoke-static {p1}, Lq0/k;->a(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    invoke-interface {p0, p1}, Ls0/d;->resumeWith(Ljava/lang/Object;)V

    return-void
.end method
