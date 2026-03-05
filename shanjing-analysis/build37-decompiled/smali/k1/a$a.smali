.class final Lk1/a$a;
.super Lkotlin/coroutines/jvm/internal/d;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lk1/a;->a(Lk1/c;Ls0/d;)Ljava/lang/Object;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x18
    name = null
.end annotation

.annotation runtime Lkotlin/coroutines/jvm/internal/f;
    c = "kotlinx.coroutines.flow.AbstractFlow"
    f = "Flow.kt"
    l = {
        0xd4
    }
    m = "collect"
.end annotation


# instance fields
.field d:Ljava/lang/Object;

.field synthetic e:Ljava/lang/Object;

.field final synthetic f:Lk1/a;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lk1/a<",
            "TT;>;"
        }
    .end annotation
.end field

.field g:I


# direct methods
.method constructor <init>(Lk1/a;Ls0/d;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lk1/a<",
            "TT;>;",
            "Ls0/d<",
            "-",
            "Lk1/a$a;",
            ">;)V"
        }
    .end annotation

    iput-object p1, p0, Lk1/a$a;->f:Lk1/a;

    invoke-direct {p0, p2}, Lkotlin/coroutines/jvm/internal/d;-><init>(Ls0/d;)V

    return-void
.end method


# virtual methods
.method public final invokeSuspend(Ljava/lang/Object;)Ljava/lang/Object;
    .locals 1

    iput-object p1, p0, Lk1/a$a;->e:Ljava/lang/Object;

    iget p1, p0, Lk1/a$a;->g:I

    const/high16 v0, -0x80000000

    or-int/2addr p1, v0

    iput p1, p0, Lk1/a$a;->g:I

    iget-object p1, p0, Lk1/a$a;->f:Lk1/a;

    const/4 v0, 0x0

    invoke-virtual {p1, v0, p0}, Lk1/a;->a(Lk1/c;Ls0/d;)Ljava/lang/Object;

    move-result-object p1

    return-object p1
.end method
