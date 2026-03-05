.class public interface abstract Ls0/e;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ls0/g$b;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Ls0/e$a;,
        Ls0/e$b;
    }
.end annotation


# static fields
.field public static final c:Ls0/e$b;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    sget-object v0, Ls0/e$b;->d:Ls0/e$b;

    sput-object v0, Ls0/e;->c:Ls0/e$b;

    return-void
.end method


# virtual methods
.method public abstract h(Ls0/d;)Ls0/d;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<T:",
            "Ljava/lang/Object;",
            ">(",
            "Ls0/d<",
            "-TT;>;)",
            "Ls0/d<",
            "TT;>;"
        }
    .end annotation
.end method

.method public abstract q(Ls0/d;)V
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ls0/d<",
            "*>;)V"
        }
    .end annotation
.end method
