.class final Lkotlinx/coroutines/internal/s$a;
.super Lkotlin/jvm/internal/j;
.source "SourceFile"

# interfaces
.implements La1/l;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lkotlinx/coroutines/internal/s;->a(La1/l;Ljava/lang/Object;Ls0/g;)La1/l;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x18
    name = null
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Lkotlin/jvm/internal/j;",
        "La1/l<",
        "Ljava/lang/Throwable;",
        "Lq0/q;",
        ">;"
    }
.end annotation


# instance fields
.field final synthetic d:La1/l;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "La1/l<",
            "TE;",
            "Lq0/q;",
            ">;"
        }
    .end annotation
.end field

.field final synthetic e:Ljava/lang/Object;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "TE;"
        }
    .end annotation
.end field

.field final synthetic f:Ls0/g;


# direct methods
.method constructor <init>(La1/l;Ljava/lang/Object;Ls0/g;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "La1/l<",
            "-TE;",
            "Lq0/q;",
            ">;TE;",
            "Ls0/g;",
            ")V"
        }
    .end annotation

    iput-object p1, p0, Lkotlinx/coroutines/internal/s$a;->d:La1/l;

    iput-object p2, p0, Lkotlinx/coroutines/internal/s$a;->e:Ljava/lang/Object;

    iput-object p3, p0, Lkotlinx/coroutines/internal/s$a;->f:Ls0/g;

    const/4 p1, 0x1

    invoke-direct {p0, p1}, Lkotlin/jvm/internal/j;-><init>(I)V

    return-void
.end method


# virtual methods
.method public final a(Ljava/lang/Throwable;)V
    .locals 2

    iget-object p1, p0, Lkotlinx/coroutines/internal/s$a;->d:La1/l;

    iget-object v0, p0, Lkotlinx/coroutines/internal/s$a;->e:Ljava/lang/Object;

    iget-object v1, p0, Lkotlinx/coroutines/internal/s$a;->f:Ls0/g;

    invoke-static {p1, v0, v1}, Lkotlinx/coroutines/internal/s;->b(La1/l;Ljava/lang/Object;Ls0/g;)V

    return-void
.end method

.method public bridge synthetic invoke(Ljava/lang/Object;)Ljava/lang/Object;
    .locals 0

    check-cast p1, Ljava/lang/Throwable;

    invoke-virtual {p0, p1}, Lkotlinx/coroutines/internal/s$a;->a(Ljava/lang/Throwable;)V

    sget-object p1, Lq0/q;->a:Lq0/q;

    return-object p1
.end method
