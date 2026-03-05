.class Lj1/a$b;
.super Lj1/o;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lj1/a;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0xa
    name = "b"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "<E:",
        "Ljava/lang/Object;",
        ">",
        "Lj1/o<",
        "TE;>;"
    }
.end annotation


# instance fields
.field public final g:Lj1/a$a;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lj1/a$a<",
            "TE;>;"
        }
    .end annotation
.end field

.field public final h:Lh1/k;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lh1/k<",
            "Ljava/lang/Boolean;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method public constructor <init>(Lj1/a$a;Lh1/k;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lj1/a$a<",
            "TE;>;",
            "Lh1/k<",
            "-",
            "Ljava/lang/Boolean;",
            ">;)V"
        }
    .end annotation

    invoke-direct {p0}, Lj1/o;-><init>()V

    iput-object p1, p0, Lj1/a$b;->g:Lj1/a$a;

    iput-object p2, p0, Lj1/a$b;->h:Lh1/k;

    return-void
.end method


# virtual methods
.method public A(Ljava/lang/Object;)La1/l;
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TE;)",
            "La1/l<",
            "Ljava/lang/Throwable;",
            "Lq0/q;",
            ">;"
        }
    .end annotation

    iget-object v0, p0, Lj1/a$b;->g:Lj1/a$a;

    iget-object v0, v0, Lj1/a$a;->a:Lj1/a;

    iget-object v0, v0, Lj1/c;->b:La1/l;

    if-nez v0, :cond_0

    const/4 p1, 0x0

    goto :goto_0

    :cond_0
    iget-object v1, p0, Lj1/a$b;->h:Lh1/k;

    invoke-interface {v1}, Ls0/d;->getContext()Ls0/g;

    move-result-object v1

    invoke-static {v0, p1, v1}, Lkotlinx/coroutines/internal/s;->a(La1/l;Ljava/lang/Object;Ls0/g;)La1/l;

    move-result-object p1

    :goto_0
    return-object p1
.end method

.method public c(Ljava/lang/Object;)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TE;)V"
        }
    .end annotation

    iget-object v0, p0, Lj1/a$b;->g:Lj1/a$a;

    invoke-virtual {v0, p1}, Lj1/a$a;->e(Ljava/lang/Object;)V

    iget-object p1, p0, Lj1/a$b;->h:Lh1/k;

    sget-object v0, Lh1/n;->a:Lkotlinx/coroutines/internal/x;

    invoke-interface {p1, v0}, Lh1/k;->r(Ljava/lang/Object;)V

    return-void
.end method

.method public g(Ljava/lang/Object;Lkotlinx/coroutines/internal/m$b;)Lkotlinx/coroutines/internal/x;
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TE;",
            "Lkotlinx/coroutines/internal/m$b;",
            ")",
            "Lkotlinx/coroutines/internal/x;"
        }
    .end annotation

    iget-object p2, p0, Lj1/a$b;->h:Lh1/k;

    sget-object v0, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    invoke-virtual {p0, p1}, Lj1/a$b;->A(Ljava/lang/Object;)La1/l;

    move-result-object p1

    const/4 v1, 0x0

    invoke-interface {p2, v0, v1, p1}, Lh1/k;->j(Ljava/lang/Object;Ljava/lang/Object;La1/l;)Ljava/lang/Object;

    move-result-object p1

    if-nez p1, :cond_0

    return-object v1

    :cond_0
    sget-object p1, Lh1/n;->a:Lkotlinx/coroutines/internal/x;

    return-object p1
.end method

.method public toString()Ljava/lang/String;
    .locals 2

    invoke-static {p0}, Lh1/m0;->b(Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    const-string v1, "ReceiveHasNext@"

    invoke-static {v1, v0}, Lkotlin/jvm/internal/i;->j(Ljava/lang/String;Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public z(Lj1/j;)V
    .locals 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lj1/j<",
            "*>;)V"
        }
    .end annotation

    iget-object v0, p1, Lj1/j;->g:Ljava/lang/Throwable;

    if-nez v0, :cond_0

    iget-object v0, p0, Lj1/a$b;->h:Lh1/k;

    sget-object v1, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    const/4 v2, 0x2

    const/4 v3, 0x0

    invoke-static {v0, v1, v3, v2, v3}, Lh1/k$a;->a(Lh1/k;Ljava/lang/Object;Ljava/lang/Object;ILjava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    goto :goto_0

    :cond_0
    iget-object v0, p0, Lj1/a$b;->h:Lh1/k;

    invoke-virtual {p1}, Lj1/j;->E()Ljava/lang/Throwable;

    move-result-object v1

    invoke-interface {v0, v1}, Lh1/k;->p(Ljava/lang/Throwable;)Ljava/lang/Object;

    move-result-object v0

    :goto_0
    if-eqz v0, :cond_1

    iget-object v1, p0, Lj1/a$b;->g:Lj1/a$a;

    invoke-virtual {v1, p1}, Lj1/a$a;->e(Ljava/lang/Object;)V

    iget-object p1, p0, Lj1/a$b;->h:Lh1/k;

    invoke-interface {p1, v0}, Lh1/k;->r(Ljava/lang/Object;)V

    :cond_1
    return-void
.end method
